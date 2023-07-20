# frozen_string_literal: true

class Mask < ApplicationRecord
  validates_presence_of :sender, :regexp_type, :regexp
end
