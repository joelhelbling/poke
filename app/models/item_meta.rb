require 'squares/base'

class ItemMeta < Squares::Base
  property :expires_at, {}
  property :access_count, default: 2
  property :limit_accesses?, default: true

  alias_method :item, :id
end
