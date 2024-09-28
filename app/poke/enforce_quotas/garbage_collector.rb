require 'models/item'
require 'models/item_meta'

module Poke
  class EnforceQuotas
    class GarbageCollector
      PERIOD = 60

      class << self
        def run
          Thread.new do
            loop do
              collect_the_garbage
              sleep PERIOD
            end
          end
          @running = true
        end

        def collect_the_garbage
          expired_items.each do |item|
            Item.delete item.id
            ItemMeta.delete item.id
          end
        end

        def running?
          @running
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
