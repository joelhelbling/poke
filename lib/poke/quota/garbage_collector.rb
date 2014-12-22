require 'eventmachine'
require 'models/item'
require 'models/item_meta'

module Poke
  class Quota
    class GarbageCollector

      PERIOD = 60

      class << self
        def run
          EM.schedule do
            EM.add_periodic_timer(PERIOD) do
              collect_the_garbage
            end
            @running = true
          end
        end

        def collect_the_garbage
          expired_items.each do |item|
            Item.delete item.id
            ItemMeta.delete item.id
          end
        end

        def running?
          EM.reactor_running? && @running
        end

        private

        def expired_items
          ItemMeta.select do |meta|
            meta.expires_at <= Time.now ||
              meta.access_count <= 0
          end
        end

      end
    end
  end
end
