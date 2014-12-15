require 'digest/sha2'

class TokenChain
  attr_reader :codes

  def initialize(anchor)
    @anchor = anchor
    @codes = []
  end

  def generate(number=1)
    number.times do
      part_one = @codes.last || @anchor.last_code || @anchor.anchor_code
      part_two = @anchor.anchor_code
      @codes << sha.digest("#{part_one}#{part_two}")
    end
    @codes.last
  end

  def sha
    @sha ||= Digest::SHA2.new
  end
end
