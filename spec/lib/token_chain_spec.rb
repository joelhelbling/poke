require 'spec_helper'

describe TokenChain do
  Given(:anchor)      { double anchor_code: anchor_code      }

  Given(:sha)         { Digest::SHA256.new                   }
  Given(:passphrase)  { 'the rain in spain'                  }
  Given(:second_seed) { sha.digest passphrase                }
  Given(:anchor_code) { sha.digest second_seed + passphrase  }
  Given(:first_code)  { sha.digest anchor_code + anchor_code }
  Given(:second_code) { sha.digest first_code  + anchor_code }
  Given(:third_code)  { sha.digest second_code + anchor_code }

  context 'anchor with no last code' do
    Given(:chain) { described_class.new anchor }

    describe 'generates a token' do
      When(:result) { chain.generate }
      Then { result == first_code }
    end

    describe 'generates multiple tokens' do
      When(:result) { chain.generate(3) }
      Then { result == third_code }
      Then { chain.codes == [ first_code, second_code, third_code ] }
    end
  end

  context 'anchor with a last code' do
    Given(:last_code)   { third_code }
    Given(:fourth_code) { sha.digest third_code  + anchor_code  }
    Given(:fifth_code)  { sha.digest fourth_code + anchor_code  }
    Given(:chain)       { described_class.new anchor, last_code }

    describe 'generates a token' do
      When(:result) { chain.generate }
      Then { result == fourth_code }
    end

    describe 'generates multiple tokens' do
      When(:result) { chain.generate(2) }
      Then { result == fifth_code }
      Then { chain.codes == [ fourth_code, fifth_code ] }
    end
  end

end
