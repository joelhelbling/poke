require 'token_chain'
require 'models/quota'
require 'models/quota_token'
module Poke
  class EnforceQuotas
    class TokenReplentisher

      PERIOD = 60*60*24 # run once every 24 hrs

      class << self

        def run
          EM.schedule do
            EM.add_periodic_timer(PERIOD) do
              replentish_tokens
            end
            @running = true
          end
        end

        def replentish_tokens
          Quota.each do |quota|
            chain = TokenChain.from_anchor quota.anchor_code, quota.last_generated_token
            available_count = QuotaToken.select do |token|
              token.anchor_code == quota.anchor_code && ! token.accessed?
            end.count
            generated = []
            (quota.max_tokens - available_count).times do
              generated << QuotaToken.create(chain.generate, anchor_code: quota.anchor_code)
            end

            quota.last_generated_token = generated.last.code
            quota.save
          end # end Quota.each
        end

        def running?
          EM.reactor_running? && @running
        end

      end
    end
  end
end


