require 'rack/request'
require 'poke/base'
require 'poke/store'

# A rack middleware which sets the lifespan of incoming items.
# It always allows the items through.  But for any items for
# which it cannot resolve a token chain, it assigns the minimum
# lifespan (DEFAULT_EXPIRE_MINUTES).
#
# It might also be good if this guy tracked IP's which didn't
# use a token chain; not only will their items expire quickly
# but we should probably cap them at x posts per hour.

module Poke
  class Quota < Base

    DEFAULT_EXPIRE_MINUTES = 60

    def initialize app
      @app             = app
      @anchor_store    = TokenAnchorStore.new
      @codes_store     = TokenChainStore.new
      @item_meta_store = ItemMetaStore.new
    end

    def call env
      req = Rack::Request.new env

      case
      when req.post?
        process_quota req
      else
        @app.call req.env
      end
    end

    private

    def process_quota req
      status, headers, content = @app.call req.env

      if status == status_code(:created)
        expire_minutes = DEFAULT_EXPIRE_MINUTES
        auth_token = req.env['HTTP_AUTHORIZATION']

        if auth = auth_token && @codes_store[ auth_token ]
          expire_minutes = @anchor_store[ auth[:anchor_code] ][:quota][:expire_in_minutes]
          auth[:accessed] ||= true
          @codes_store[ auth_token ] = auth
        end

        expire_time = expire_in_minutes(expire_minutes)
        @item_meta_store[req.path] = { expires_at: expire_time }
        content << "\nItem will expire at #{expire_time.utc}"
      end
      [ status, headers, content ]
    end

    def expire_in_minutes minutes
      Time.now + minutes * 60
    end
  end

  class ItemMetaStore < Store; end
  class TokenChainStore < Store; end
  class TokenAnchorStore < Store; end

end
