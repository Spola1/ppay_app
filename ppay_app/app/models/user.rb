# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :lockable

  has_one :balance, as: :balanceable, dependent: :destroy
  has_one :crypto_wallet, dependent: :destroy

  has_many :api_keys, as: :bearer
  has_many :comments
  has_many :chats
  has_many :balance_requests

  before_create :set_crypto_wallet
  after_create :create_balance, :create_api_key
  before_save :extract_username_from_telegram

  validates :telegram, format: { with: /\Ahttps?:\/\/t\.me\/\w+\z/ }, allow_blank: true

  # validates_presence_of :crypto_wallet

  %i[admin agent merchant processer support].each do |role|
    define_method("#{role}?") do
      type == role.to_s.camelize
    end
  end

  def token
    api_keys.last.token
  end

  private

  def extract_username_from_telegram
    if telegram.present?
      self.telegram = telegram.split('/').last
    end
  end

  def create_api_key
    api_keys.create
  end

  def set_crypto_wallet
    self.crypto_wallet = CryptoWallet.free.first
  end
end
