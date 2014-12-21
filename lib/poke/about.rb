require 'rack/request'
require 'poke/rack_tools'

module Poke
  class About
    include RackTools

    WATCHED_PATHS = %w{ / /about }
    ABOUT_CONTENT = "Poking about?"

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new env

      if WATCHED_PATHS.include? req.path
        render_about req
      else
        @app.call req.env
      end

    end

    def render_about req
      if req.get?
        render content: ABOUT_CONTENT
      else
        render status: :not_allowed
      end
    end

  end
end
