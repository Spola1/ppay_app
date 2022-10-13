# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it { is_expected.to belong_to(:from_balance).class_name('Balance') }
  it { is_expected.to belong_to(:to_balance).class_name('Balance') }
  it { is_expected.to belong_to(:payment) }
end
