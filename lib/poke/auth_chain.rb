require 'digest/sha2'

# A spike.  The actual algorithm is now somewhat different.
# Save to a spike branch.
module Poke
  class AuthChain
    attr_reader :hashes

    def initialize(seed)
      @gen = Digest::SHA256.new
      @seed1 = seed
      @seed2 = @gen.base64digest @seed1
      @hashes = [ @seed1, @seed2 ]
    end

    def valid?(hash)
      return true if @hashes.slice(2..-1).include?(hash)
      found = false
      attempts = 1000
      until found || attempts < 1
        attempts -= 1
        if hash == next_hash
          found = true
        end
      end
      found
    end

    def next_hash
      (@hashes << @gen.base64digest(last_two.join)).last
    end

    def last
      length > 0 ? @hashes.last : nil
    end

    def [](index)
      @hashes[ index + 2 ]
    end

    def length
      @hashes.size - 2
    end

    def size
      length
    end

    private

    def last_two
      @hashes.slice(-2,2)
    end

  end
end
