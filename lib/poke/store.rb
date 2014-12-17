module Poke
  class Store
    STORE = ENV['LEVELDB_STORE']

    def [] key
      if item = store[key]
        begin
          Marshal.restore item
        rescue TypeError
          { content_type: 'text/plain', content: [ item ] }
        end
      end
    end

    def []= key, value
      store[key] = Marshal.dump value
    end

    def exists? key
      store.exists? key
    end

    def keys
      store.keys
    end

    def store
      @@store ||= LevelDB::DB.new STORE
    end
  end
end