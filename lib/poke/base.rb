module Poke
  class Base

    STATUS_MAP = {
      ok:           200,
      created:      201,
      forbidden:    403,
      not_found:    404,
      not_allowed:  405
    }

    private

    def key_from(env)
      env['PATH_INFO']
    end

    def method_from(env)
      env['REQUEST_METHOD']
    end

    def render(status: :ok, content_type: "text/html", content: [])
      [ status_code(status), {"Content-Type" => content_type}, [content].flatten ]
    end

    def status_code(status_symbol)
      status_code = status_symbol.is_a?(Fixnum) ? status_symbol : STATUS_MAP[status_symbol]
    end

  end
end
