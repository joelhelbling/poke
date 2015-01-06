require 'squares/base'

class Quota < Squares::Base
  property :quota_in_minutes, default: 24*60

  alias_method :anchor_code, :id
end
