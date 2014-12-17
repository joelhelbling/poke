# A rack middleware which sets the lifespan of incoming items.
# It always allows the items through.  But for any items for
# which it cannot resolve a token chain, it gets the minimum
# lifespan (TBD minutes).
#
# It might also be good if this guy tracked IP's which didn't
# use a token chain; not only will their items expire quickly
# but we should probably cap them at x posts per hour.
module Poke
  class Quota

    def initialize app, anchor_store: {}, codes_store: {}, item_meta_store: {}
      @app             = app
      @anchor_store    = anchor_store
      @codes_store     = codes_store
      @item_meta_store = item_meta_store
    end

    def call env
      case env['REQUEST_METHOD']
      when 'POST'
        process_quota env
      else
        @app.call env
      end
    end

    def process_quota env
      # ensure no spoofed quota is present in ENV['HEADERS']
      #   -- we don't have to embed this in headers.  We can set
      #      arbitrary fields in the env.  Furthermore, because
      #      we can confirm the write went ok, we can simply
      #      write the quota meta information afterwards, as
      #      the response is on its way back out.
      #
      # if anchor = resolve token chain
      #   quota from anchor
      # else
      #   minimum quota
      #
      # write quota to item meta info
      # append quota response to content

      status, headers, content = @app.call env
      [ status, headers, content ]
    end
  end
end
