# frozen_string_literal: true

class ExchangePortal < ApplicationRecord
  has_many :rate_snapshots

  def settings
    return super if super

    self.settings = {}
    super
  end
end
