require 'spec_helper'
require 'models/quota'
require 'models/quota_token'
require 'token_chain'
require 'poke/enforce_quotas/token_replentisher'

describe Poke::EnforceQuotas::TokenReplentisher do
  Given { Quota.store      = {} }
  Given { QuotaToken.store = {} }
  Given(:chain) { TokenChain.from_passphrase 'the rain in spain' }
  Given(:first_code) do
    QuotaToken.create chain.generate,
      anchor_code: chain.anchor_code,
      accessed_at: accessed_at
  end
  Given do
    Quota.create chain.anchor_code,
      max_tokens: 3,
      last_generated_token: first_code.id
  end
  When { described_class.replentish_tokens }

  describe 'existing token not accessed' do
    Given(:accessed_at) { nil }
    Then { expect(QuotaToken.count).to eq(3) }
  end

  describe 'existing token is accessed' do
    Given(:accessed_at) { Time.now - 100 }
    Then { expect(QuotaToken.count).to eq(4) }
  end

end
