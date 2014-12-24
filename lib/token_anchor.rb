require 'digest/sha2'

module TokenAnchor
  class << self

    def from passphrase
      second_seed = sha.base64digest passphrase
      sha.base64digest second_seed + passphrase
    end

    private

    def sha
      @sha ||= Digest::SHA256.new
    end
  end

end

