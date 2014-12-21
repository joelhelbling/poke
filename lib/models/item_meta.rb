require 'squares/base'

class ItemMeta < Squares::Base
  property :expires_at, {}

  alias_method :item, :id
end
