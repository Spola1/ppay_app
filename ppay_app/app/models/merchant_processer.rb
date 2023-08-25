class MerchantProcesser < ApplicationRecord
  belongs_to :merchant
  belongs_to :processer
end
