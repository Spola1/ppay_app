class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :lockable

  has_many :api_keys, as: :bearer
  has_one :balance, as: :balanceable, dependent: :destroy

  before_create :generate_rsa_key_pair
  after_create :create_balance, :create_api_key

  private

  def create_api_key
    api_keys.create
  end

  def generate_rsa_key_pair
    key = OpenSSL::PKey::RSA.generate(2048)
    self.rsa_public_key = key.public_key.to_s
    self.rsa_private_key = key.to_s
  end
end
