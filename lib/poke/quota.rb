require 'poke/base'

# A rack middleware which sets the lifespan of incoming items.
# It always allows the items through.  But for any items for
# which it cannot resolve a token chain, it gets the minimum
# lifespan (TBD minutes).
#
# It might also be good if this guy tracked IP's which didn't
# use a token chain; not only will their items expire quickly
# but we should probably cap them at x posts per hour.
module Poke
  class Quota < Base

    DEFAULT_EXPIRE_MINUTES = 60
    def initialize app, anchor_store: {}, codes_store: {}, item_meta_store: {}
      @app             = app
      @anchor_store    = anchor_store
      @codes_store     = codes_store
      @item_meta_store = item_meta_store
    end

    def call env
      case method_from(env)
      when 'POST'
        process_quota env
      else
        @app.call env
      end
    end

    private

    def process_quota env
      status, headers, content = @app.call env

      if status == status_code(:created)
        expire_minutes = DEFAULT_EXPIRE_MINUTES
        auth_token = env['HTTP_AUTHORIZATION']

        if auth = auth_token && @codes_store[ auth_token ]
          expire_minutes = @anchor_store[ auth[:anchor_code] ][:quota][:expire_in_minutes]
          auth[:accessed] ||= true
          @codes_store[ auth_token ] = auth
        end

        expire_time = expire_in_minutes(expire_minutes)
        @item_meta_store[key_from env] = { expires_at: expire_time }
        content << "\nItem will expire at #{expire_time.utc}"
      end
      [ status, headers, content ]
    end

    def expire_in_minutes minutes
      Time.now + minutes * 60
    end
  end
end
