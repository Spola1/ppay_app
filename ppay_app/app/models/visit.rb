# frozen_string_literal: true

class Visit < ApplicationRecord
  belong_to :payment
end
