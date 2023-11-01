# frozen_string_literal: true

class MobileAppRequest < ApplicationRecord
  belongs_to :user, optional: true
end
