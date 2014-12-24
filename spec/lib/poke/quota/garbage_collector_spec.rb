require 'spec_helper'
require 'poke/quota/garbage_collector'
require 'models/item'
require 'models/item_meta'

describe Poke::Quota::GarbageCollector do
  Given { Item.store     = {} }
  Given { ItemMeta.store = {} }
  Given(:time) { Time.now }
  Given { Timecop.freeze time }
  Given(:path) { '/abc/123' }
  Given(:accesses) { 1 }
  Given { Item.create path, content: [ 'some content' ] }
  Given { ItemMeta.create path, expires_at: expire_time, access_count: accesses }

  When { described_class.collect_the_garbage }

  context 'item has not expired' do
    Given(:expire_time) { time + 1 }

    context 'item has accesses remaining' do
      Then { expect(Item).to be_key(path) }
      Then { expect(ItemMeta).to be_key(path) }
    end

    context 'item has no accesses remaining' do
      Given(:accesses) { 0 }
      Then { expect(Item).to_not be_key(path) }
      Then { expect(ItemMeta).to_not be_key(path) }
    end
  end

  context 'item has expired' do
    Given(:expire_time) { time - 1 }
    Then { expect(Item).to_not be_key(path) }
    Then { expect(ItemMeta).to_not be_key(path) }
  end

end
