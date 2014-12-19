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
    Given(:chain)       { TokenChain.new anchor_code                }
    Given(:first_code)  { chain.generate                            }

    #storage
    Given do
      TokenAnchorStore.datastore = {}
      TokenChainStore.datastore = {}
      ItemMetaStore.datastore = {}
    end
    Given(:anchor_store)    { TokenAnchorStore.new }
    Given(:codes_store)     { TokenChainStore.new  }
    Given(:item_meta_store) { ItemMetaStore.new    }
    Given do
      anchor_store[anchor_code] = {
        second_seed: second_seed,
        quota: { expire_in_minutes: 24 * 60 }
      }
    end
    Given do
      codes_store[first_code] = {
        predecessor:  anchor_code,
        anchor_code:  anchor_code,
        sequence:     1,
        accessed:     nil
      }
    end

    # setup middleware
    Given(:app)   { double }
    Given(:quota) { Quota.new app }
    Given(:env) do
      {
        'PATH_INFO'      => '/el/stuff',
        'REQUEST_METHOD' => method
      }
    end

    When(:result) { quota.call env }

    context 'GET' do
      Given(:method) { 'GET' }

      Given { expect(app).to receive(:call).with(env) }
      Then  { expect(item_meta_store).to be_none      }
      Then  { not codes_store[first_code][:accessed]  }
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
        Then { item_meta_store['/el/stuff'] == { expires_at: minimum_quota } }
        # Then { expect(result[2]).to include('minimum quota') }
      end

      context 'invalid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = 'bogus_code' }
        Then { item_meta_store['/el/stuff'] == { expires_at: minimum_quota } }

      end

      context 'valid token chain' do
        Given { env['HTTP_AUTHORIZATION'] = first_code }

        Then { codes_store[first_code][:accessed] == true }
        Then { item_meta_store['/el/stuff'] == { expires_at: quota_24_hours } }
      end

    end
  end
end
