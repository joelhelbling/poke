require 'rack/request'
require 'poke/rack_tools'
require 'poke/enforce_quotas/garbage_collector'
require 'models/quota'
require 'models/quota_token'
require 'models/item_meta'

# A rack middleware which sets the lifespan of incoming items.
# It always allows the items through.  But for any items for
# which it cannot resolve a token chain, it assigns the minimum
# lifespan (DEFAULT_EXPIRE_MINUTES).
#
# It might also be good if this guy tracked IP's which didn't
# use a token chain; not only will their items expire quickly
# but we should probably cap them at x posts per hour.

module Poke
  class EnforceQuotas
    include RackTools

    DEFAULT_EXPIRE_MINUTES = 60

    def initialize app
      @app = app

      GarbageCollector.run
    end

    def call env
      req = Rack::Request.new env

      case
      when req.post?
        process_quota req
      else
        decrement_access_count req
        @app.call req.env
      end
    end

    private

    def decrement_access_count req
      if meta = ItemMeta.find(req.path)
        meta.access_count -= 1
        meta.save
      end
    end

    def process_quota req
      status, headers, content = @app.call req.env

      if status == status_code(:created)
        expire_minutes = DEFAULT_EXPIRE_MINUTES

        auth_token = req.env['HTTP_AUTHORIZATION']

        if auth = QuotaToken.find(auth_token)
          anchor = Quota.find auth.anchor_code
          expire_minutes = anchor.quota_in_minutes
          auth.accessed = true
          auth.save
        end

        expire_time = expire_time_from_minutes expire_minutes

        ItemMeta.create req.path, expires_at: expire_time
        content << "\nItem will expire at #{expire_time.utc}"
      end

      [ status, headers, content ]
    end

    def expire_time_from_minutes minutes
      Time.now + minutes * 60
    end
  end

end
