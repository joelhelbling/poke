require 'token_chain'
require 'models/quota'
require 'models/quota_token'

module Poke
  class EnforceQuotas
    class TokenReplentisher
      PERIOD = 60*60*24 # run once every 24 hrs

      class << self
        def run
          Thread.new do
            loop do
              replentish_tokens
              sleep PERIOD
            end
          end
          @running = true
        end

        def replentish_tokens
          Quota.each do |quota|
            chain = TokenChain.from_anchor quota.anchor_code, quota.last_generated_token
            available_count = QuotaToken.select do |token|
              token.anchor_code == quota.anchor_code && !token.accessed?
            end.count
            generated = []
            (quota.max_tokens - available_count).times do
              generated << QuotaToken.create(chain.generate, anchor_code: quota.anchor_code)
            end

            quota.last_generated_token = generated.last.code if generated.last
            quota.save
          end
        end

        def running?
          @running
        end
      end
    end
  end
end


