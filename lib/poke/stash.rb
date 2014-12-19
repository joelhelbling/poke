require 'rack/request'
require 'leveldb'
require 'poke/base'
require 'poke/store'

module Poke
  class Stash < Base

    def initialize(datastore: ItemStore.new)
      @store = datastore
    end

    def call(env)
      req = Rack::Request.new env
      key = req.path

      case
      when req.get?
        if item = @store[key]
          render content_type: item[:content_type], content: item[:content]
        else
          render status: :not_found
        end
      when req.post?
        if @store.has_key? key
          render status: :forbidden
        else
          @store[key] = {
            content_type: req.content_type,
            content:      req.body.readlines }
          render status: :created, content: [ "\nItem \"#{key}\" saved successfully." ]
        end
      else
        render status: :not_allowed
      end
    end

  end

  class ItemStore < Store
    def handle_unmarshal_error item
      { content_type: 'text/plain', content: [ item ] }
    end
  end

end
