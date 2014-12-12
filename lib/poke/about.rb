module Poke
  class About < Base

    WATCHED_PATHS = %w{ / /about }

    def initialize(app)
      @app = app
    end

    def call(env)
      if WATCHED_PATHS.include?(key_from env)
        case method_from(env)
        when 'GET'
          render content: "Poking about?"
        else
          render status: :not_allowed
        end
      else
        @app.call env
      end
    end
  end
end
