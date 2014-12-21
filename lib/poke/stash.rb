require 'rack/request'
require 'leveldb'
require 'poke/base'
require 'models/item'

module Poke
  class Stash < Base

    def call(env)
      req = Rack::Request.new env
      item_id = req.path

      case
      when req.get?
        if item = Item[item_id]
          render content_type: item.content_type, content: item.content
        else
          render status: :not_found
        end
      when req.post?
        if Item.has_key? item_id
          render status: :forbidden
        else
          Item.create item_id,
            content_type: req.content_type,
            content:      req.body.readlines
          render status: :created, content: [ "\nItem \"#{item_id}\" saved successfully." ]
        end
      else
        render status: :not_allowed
      end
    end

  end
end
