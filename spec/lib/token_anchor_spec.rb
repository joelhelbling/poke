require 'spec_helper'
require 'token_anchor'

describe TokenAnchor do
  Given(:sha) { Digest::SHA256.new }
  Given(:passphrase) { 'the rain in spain' }
  Given(:second_seed) { sha.base64digest passphrase                }
  Given(:anchor_code) { sha.base64digest second_seed + passphrase  }
  When(:anchor) { TokenAnchor.from passphrase }

  context 'instantiation' do
    Then { anchor == anchor_code }
  end
end
