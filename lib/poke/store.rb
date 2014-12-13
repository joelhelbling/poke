module Poke
  class Store
    STORE = ENV['LEVELDB_STORE']

    def [] key
      store[key]
    end

    def []= key, value
      store[key] = value
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
