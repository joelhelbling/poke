require 'squares/base'

class Item < Squares::Base
  property :content_type, default: 'text/plain'
  property :content, {}
end
