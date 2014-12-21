require 'squares/base'

class TokenChainAnchor < Squares::Base
  property :second_seed, {}
  property :quota_in_minutes, default: 60

  alias_method :anchor_code, :id
end
