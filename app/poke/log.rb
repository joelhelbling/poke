require 'rack/request'

module Poke
  class Log

    def initialize app, output: $stdout
      @app = app
      @output = output
    end

    def call env
      req = Rack::Request.new env

      if debugging
        log_request req
      end

      status, headers, content = @app.call req.env

      if debugging
        log_response status, headers, content
      end

      [ status, headers, content ]
    end

    private

    def debugging
      ENV['LOG_LEVEL'] == 'DEBUG' || ENV['DEBUG']
    end

    def log_request req
      @output.print <<-LOG

      REQUEST RECEIVED __________________________
      LOG

      logged_keys = req.env.keys.select{ |k| k.match(/^[A-Z0-9\_]+$/) }
      pad_length = logged_keys.sort{|a,b| a.length <=> b.length}.last.length
      logged_keys.sort.each do |k|
        @output.printf "      %-#{pad_length}s = %s\n", k, req.env[k]
      end
    end

    def log_response status, headers, content
      @output.print <<-LOG

      RESPONSE RETURNED _________________________
      status:  #{status}
      headers: #{headers.inspect}
      content:
      #{ content.join('')[0...200] }
      LOG
    end
  end
end
