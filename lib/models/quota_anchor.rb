require 'squares/base'

class QuotaAnchor < Squares::Base
  property :quota_in_minutes, default: 24*60

  alias_method :anchor_code, :id
end
