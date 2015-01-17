require 'rack/request'
require 'poke/rack_tools'
require 'views/about_page'

module Poke
  class About
    include RackTools

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new env

      if watched?(req.path)
        render_about req
      else
        @app.call req.env
      end
    end

    def watched?(path)
      path.match(/^\/about/) || path == '/'
    end

    def redirect
      [ status_code(:moved_permanently), { "Location" => '/about' }, [] ]
    end

    def render_about req
      if req.get?
        if req.path == '/about'
          render content: about_content, content_type: 'text/html'
        else
          redirect
        end
      else
        render status: :not_allowed
      end
    end

    def about_content
      load 'views/about_page.rb' if ENV['DEBUG']
      AboutPage.render
    end

  end
end
