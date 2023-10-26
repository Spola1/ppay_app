# frozen_string_literal: true

class ExchangePortal < ApplicationRecord
  has_many :rate_snapshots
end
