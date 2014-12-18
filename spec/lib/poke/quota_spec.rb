require 'spec_helper'
require 'poke/quota'
require 'token_chain'
require 'digest/sha2'

describe Poke::Quota do

  Given(:sha)         { Digest::SHA256.new                        }
  Given(:passphrase)  { 'the rain in spain'                       }
  Given(:second_seed) { sha.base64digest passphrase               }
  Given(:anchor_code) { sha.base64digest second_seed + passphrase }
  Given(:chain)       { TokenChain.new anchor_code                }
  Given(:first_code)  { chain.generate                            }

  #storage
  Given(:anchor_store) do
    {
      anchor_code => {
        second_seed: second_seed,
        quota: { expire_in_minutes: 24 * 60 }
      }
    }
  end
  Given(:codes_store) do
    {
      first_code => {
        predecessor:  anchor_code,
        anchor_code:  anchor_code,
        sequence:     1,
        accessed:     nil
      }
    }
  end
  Given(:item_meta_store) { {} }

  # setup middleware
  Given(:app)   { double }
  Given(:quota) do
    Poke::Quota.new app,
      anchor_store: anchor_store,
      codes_store: codes_store,
      item_meta_store: item_meta_store
  end
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
    Then  { item_meta_store == {} }
    Then  { not codes_store[first_code][:accessed] }
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
      Then { item_meta_store == { '/el/stuff' => { expires_at: minimum_quota } } }
      # Then { expect(result[2]).to include('minimum quota') }
    end

    context 'invalid token chain' do
      Given { env['HTTP_AUTHORIZATION'] = 'bogus_code' }
      Then { item_meta_store == { '/el/stuff' => { expires_at: minimum_quota } } }

    end

    context 'valid token chain' do
      Given { env['HTTP_AUTHORIZATION'] = first_code }

      Then { codes_store[first_code][:accessed] == true }
      Then { item_meta_store == { '/el/stuff' => { expires_at: quota_24_hours } } }
    end

  end
end
