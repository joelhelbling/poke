require 'squares/base'

class ItemMeta < Squares::Base
  property :expires_at, {}
  property :access_count, default: 1

  alias_method :item, :id
end
