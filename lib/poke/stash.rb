require 'json'

module Poke
  class Stash < Base

    def initialize(datastore: {})
      @store = datastore
    end

    def call(env)
      key = key_from env

      case method_from(env)
      when 'GET'
        if serialized_item = @store[key]
          item = JSON.parse serialized_item
          render content_type: item['content_type'], content: item['content']
        else
          render status: :not_found
        end
      when 'POST'
        @store[key] = {
          content_type:  env['CONTENT_TYPE'],
          content:       env['rack.input'].readlines }.to_json
        render status: :created
      else
        render status: :not_allowed
      end
    end

  end
end
