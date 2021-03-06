require 'spec_helper'
require 'poke/enforce_quotas'
require 'token_chain'

module Poke
  describe EnforceQuotas do

    Given(:passphrase)  { 'the rain in spain'                       }
    Given(:chain)       { TokenChain.from_passphrase passphrase     }
    Given(:anchor_code) { chain.anchor_code                         }
    Given(:first_code)  { chain.generate                            }

    Given do
      Quota.create anchor_code,
        quota_in_minutes: 24 * 60,
        quota_in_accesses: 7,
        limit_accesses?: limit_accesses
      QuotaToken.create first_code,
        anchor_code:  anchor_code
    end

    # setup middleware
    Given(:app)      { double                  }
    Given(:enforcer) { described_class.new app }
    Given(:path)     { '/el/stuff'             }
    Given(:env) do
      {
        'PATH_INFO'      => path,
        'REQUEST_METHOD' => method
      }
    end
    Given(:limit_accesses) { true }

    When(:result) { enforcer.call env }

    context 'GET' do
      Given(:method) { 'GET' }
      Given do
        ItemMeta.create path, expires_at: Time.now + 10000, access_count: 2, limit_accesses?: limit_accesses
      end

      context 'when limiting accesses' do
        Given(:limit_accesses) { true }

        describe 'passes the request on' do
          Given { expect(app).to receive(:call).with(env)      }
          Then  { expect(ItemMeta.store.keys.count).to eq(1)   }
          Then  { expect(QuotaToken[first_code]).to_not be_accessed }
        end

        describe 'decrements the item access count' do
          Then { ItemMeta[path].access_count == 1 }
        end
      end

      context 'when NOT limiting accesses' do
        Given(:limit_accesses) { false }

        describe 'does not decrement the access count if limit accesses is false' do
          Then { ItemMeta[path].access_count == 2 }
        end
      end
    end

    context 'POST' do
      Given(:method) { 'POST' }
      Given(:response) { [ 201, { 'Content-Type' => 'text/plain' }, [ 'Success' ] ] }
      Given { allow(app).to receive(:call).with(env).and_return(response) }
      Given(:content) { 'Hello World' }
      Given { env['rack.input'] = StringIO.new content }
      Given(:time) { Time.now }
      Given(:minimum_quota) { time + 60*60 }
      Given(:quota_24_hours) { time + 24*60*60 }
      Given { Timecop.freeze time }

      context 'no Authorization provided' do
        Then { ItemMeta['/el/stuff'].expires_at == minimum_quota }
        Then { ItemMeta['/el/stuff'].access_count == 2 }
      end

      context 'invalid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = 'bogus_code' }

        Then { ItemMeta['/el/stuff'].expires_at == minimum_quota }
        Then { ItemMeta['/el/stuff'].access_count == 2 }
      end

      context 'valid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = first_code }

        Then { expect(QuotaToken[first_code]).to be_accessed }
        Then { ItemMeta['/el/stuff'].expires_at == quota_24_hours }
        Then { ItemMeta['/el/stuff'].access_count == 7 }
      end

    end
  end
end
