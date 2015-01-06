require 'spec_helper'
require 'poke/quota'
require 'token_chain'
require 'digest/sha2'

module Poke
  describe Quota do

    Given(:sha)         { Digest::SHA256.new                        }
    Given(:passphrase)  { 'the rain in spain'                       }
    Given(:second_seed) { sha.base64digest passphrase               }
    Given(:anchor_code) { sha.base64digest second_seed + passphrase }
    Given(:chain)       { TokenChain.from_anchor anchor_code        }
    Given(:first_code)  { chain.generate                            }

    Given do
      QuotaAnchor.create anchor_code,
        second_seed: second_seed,
        quota_in_minutes: 24 * 60
    end
    Given do
      QuotaToken.create first_code,
        predecessor:  anchor_code,
        anchor_code:  anchor_code,
        sequence:     1
    end

    # setup middleware
    Given(:app)   { double }
    Given(:quota) { Quota.new app }
    Given(:path) { '/el/stuff' }
    Given(:env) do
      {
        'PATH_INFO'      => path,
        'REQUEST_METHOD' => method
      }
    end

    When(:result) { quota.call env }

    context 'GET' do
      Given { ItemMeta.create path, expires_at: Time.now + 10000, access_count: 2 }
      Given(:method) { 'GET' }

      describe 'passes the request on' do
        Given { expect(app).to receive(:call).with(env)      }
        Then  { expect(ItemMeta.store.keys.count).to eq(1)   }
        Then  { expect(QuotaToken[first_code]).to_not be_accessed }
      end

      describe 'decrements the item access count' do
        Then { ItemMeta[path].access_count == 1 }
      end
    end

    context 'POST' do
      Given(:response) { [ 201, { 'Content-Type' => 'text/plain' }, [ 'Success' ] ] }
      Given { allow(app).to receive(:call).with(env).and_return(response) }
      Given(:method) { 'POST' }
      Given(:content) { 'Hello World' }
      Given { env['rack.input'] = StringIO.new content }
      Given(:time) { Time.now }
      Given(:minimum_quota) { time + 60*60 }
      Given(:quota_24_hours) { time + 24*60*60 }
      Given { Timecop.freeze time }

      context 'no Authorization provided' do
        Then { ItemMeta['/el/stuff'].expires_at == minimum_quota }
        # Then { expect(result[2]).to include('minimum quota') }
      end

      context 'invalid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = 'bogus_code' }
        Then { ItemMeta['/el/stuff'].expires_at == minimum_quota }

      end

      context 'valid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = first_code }

        Then { expect(QuotaToken[first_code]).to be_accessed }
        Then { ItemMeta['/el/stuff'].expires_at == quota_24_hours }
      end

    end
  end
end
