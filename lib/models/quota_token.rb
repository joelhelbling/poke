require 'squares/base'

class QuotaToken < Squares::Base
  property :anchor_code, {}
  property :accessed_at, {}

  alias_method :token, :id
  alias_method :code, :id

  def accessed?
    ! accessed_at.nil?
  end
end
