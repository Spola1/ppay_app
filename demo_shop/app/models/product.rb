class Product < ApplicationRecord
  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items
  has_many_attached :photos
  accepts_nested_attributes_for :line_items
  # validates_associated :photos
  validates :photos, attached: true
end
