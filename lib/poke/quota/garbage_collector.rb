require 'eventmachine'

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
          puts "The garbage collector is running!"
        end

        def running?
          EM.reactor_running? && @running
        end

      end
    end
  end
end
