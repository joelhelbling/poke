require 'squares/base'

class Token < Squares::Base
  property :predecessor, {}
  property :anchor_code, {}
  property :sequence, {}
  property :accessed?, default: false

  alias_method :token, :id
end