# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, # :registerable,
         :rememberable, :trackable, :validatable, :lockable

  has_one :balance, as: :balanceable, dependent: :destroy
  has_one :crypto_wallet, dependent: :destroy
  belongs_to :working_group, optional: true
  belongs_to :agent, optional: true

  has_many :api_keys, as: :bearer
  has_many :comments
  has_many :chats
  has_many :balance_requests
  has_many :incoming_requests
  has_many :message_read_statuses

  before_create :set_crypto_wallet
  after_create :create_balance, :create_api_key

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

  def create_api_key
    api_keys.create
  end

  def set_crypto_wallet
    self.crypto_wallet = CryptoWallet.free.first
  end
end
