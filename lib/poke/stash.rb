require 'leveldb'
require 'poke/base'
require 'poke/store'

module Poke
  class Stash < Base

    def initialize(datastore: ItemStore.new)
      @store = datastore
    end

    def call(env)
      key = key_from env

      case method_from(env)
      when 'GET'
        if item = @store[key]
          render content_type: item[:content_type], content: item[:content]
        else
          render status: :not_found
        end
      when 'POST'
        if @store.has_key? key
          render status: :forbidden
        else
          @store[key] = {
            content_type: env['CONTENT_TYPE'],
            content:      env['rack.input'].readlines }
          render status: :created, content: [ "\nItem \"#{key_from env}\" saved successfully." ]
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
