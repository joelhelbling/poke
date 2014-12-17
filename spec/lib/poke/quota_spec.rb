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
      anchor_code: anchor_code,
      second_seed: second_seed,
      quota: { expire_in_hours: 24, delete_after_accesses: 3 }
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
  Given(:quota) { Poke::Quota.new app }
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
    Given(:method) { 'POST' }
    Given(:content) { 'Hello World' }
    Given { env['rack.input'] = StringIO.new content }

    context 'no Authorization provided'

    context 'invalid token chain' do
      Given { 'merge bogus Authorization header into env...' }

    end

    context 'valid token chain' do
      Given { 'merge valid Authorization header into env...' }

    end

  end
end
