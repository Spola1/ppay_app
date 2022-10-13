class ApiKey < ApplicationRecord
  belongs_to :bearer, polymorphic: true

  before_create :set_token

  private

  def set_token
  	self.token = SecureRandom.hex(24)
  end
end
