# frozen_string_literal: true

require 'rails_helper'
require 'models/concerns/balanceable'
require 'models/concerns/after_create_balance'

RSpec.describe User, type: :model do
  it_behaves_like 'balanceable'
  it_behaves_like 'after_create_balance'
  it { is_expected.to have_many(:api_keys) }
  it { is_expected.to have_many(:comments) }
  it { is_expected.to have_many(:balance_requests) }
  it { is_expected.to have_one(:balance) }
  it { is_expected.to have_one(:crypto_wallet) }
end
