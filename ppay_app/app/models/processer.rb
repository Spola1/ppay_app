# frozen_string_literal: true

class Processer < User
  include TelegramProcessable

  has_many :advertisements, foreign_key: :processer_id
  has_many :payments, through: :advertisements
  has_many :deposits, through: :advertisements
  has_many :withdrawals, through: :advertisements

  has_many :merchant_processers, dependent: :destroy

  belongs_to :working_group, optional: true
end
