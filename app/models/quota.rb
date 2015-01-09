require 'squares/base'

class Quota < Squares::Base
  property :quota_in_minutes, default: 24*60
  property :max_tokens, default: 1000
  property :last_generated_token, default: nil

  alias_method :anchor_code, :id
end
