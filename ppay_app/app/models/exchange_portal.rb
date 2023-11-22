# frozen_string_literal: true

class ExchangePortal < ApplicationRecord
  has_many :rate_snapshots

  validates_uniqueness_of :name
end
