require 'rack/request'
require 'leveldb'
require 'poke/rack_tools'
require 'models/item'
require 'json'

module Poke
  class Stash
    include RackTools

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
          render status: :created, content: [ jsonify(item_id, req.content_type) ]
        end
      else
        render status: :not_allowed
      end
    end

    private

    def jsonify(item_id, content_type)
      { "itemId" => item_id, "Content-Type" => content_type }.to_json
    end
  end
end
