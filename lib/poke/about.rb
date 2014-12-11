module Poke
  class About
    WATCHED_PATHS = %w{ / /about }
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'GET' && WATCHED_PATHS.include?(env['PATH_INFO'])
        [ 200, { "Content-Type" => "text/html" }, ["Poking about?"] ]
      else
        @app.call env
      end
    end
  end
end
