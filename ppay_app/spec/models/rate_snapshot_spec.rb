# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateSnapshot, type: :model do
  it { is_expected.to have_many(:payments) }
end
