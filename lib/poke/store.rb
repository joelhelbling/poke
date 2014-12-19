module Poke
  class Store
    class << self
      attr_accessor :datastore
    end

    def store
      self.class.datastore
    end

    def [] key
      if item = store[key]
        begin
          Marshal.restore item
        rescue TypeError
          handle_unmarshal_error item
        end
      end
    end

    def []= key, value
      store[key] = Marshal.dump value
    end

    def has_key? key
      store.has_key? key
    end
    alias_method :key?,      :has_key?
    alias_method :includes?, :has_key?
    alias_method :member?,   :has_key?

    def none?
      store.none?
    end

    def keys
      store.keys
    end

    def handle_unmarshal_error item
      raise "Looks like we need a #handle_unmarshal_error method for #{self}"
    end

  end
end
