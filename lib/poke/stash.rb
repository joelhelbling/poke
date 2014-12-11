require 'json'

module Poke
  class Stash

    def initialize(datastore: {})
      @store = datastore
    end

    def call(env)
      key = key_from env

      case env['REQUEST_METHOD']
      when 'GET'
        item = JSON.parse @store[key]
        if item
          render content_type: item['content_type'], content: item['content']
        else
          render status: 404
        end
      when 'POST'
        @store[key] = {
          content_type:  env['CONTENT_TYPE'],
          content:       env['rack.input'].readlines }.to_json
        render status: 201
      else
        render status: 401
      end
    end

    private

    def key_from(env)
      env['PATH_INFO']
    end

    def render(status: 200, content_type: "text/html", content: [])
      [ status, {"Content-Type" => content_type}, content ]
    end

  end
end
