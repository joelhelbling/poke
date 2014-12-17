require 'digest/sha2'

class TokenChain
  attr_reader :codes

  def initialize(anchor, last_code=nil)
    @anchor = anchor
    @last_code = last_code
    @codes = []
  end

  def generate(number=1)
    generated_codes = []
    number.times do
      part_one = @codes.last || @last_code || @anchor.anchor_code
      part_two = @anchor.anchor_code
      code = sha.digest("#{part_one}#{part_two}")
      @codes << code
      generated_codes << code
    end
    number > 1 ? generated_codes : @codes.last
  end

  def sha
    @sha ||= Digest::SHA2.new
  end
end
