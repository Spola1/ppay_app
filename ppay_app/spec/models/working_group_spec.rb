# frozen_string_literal: true

require 'rails_helper'
require 'models/concerns/balanceable'
require 'models/concerns/after_create_balance'

RSpec.describe WorkingGroup, type: :model do
  it { is_expected.to have_many(:processers) }
  it { is_expected.to have_one(:balance) }
  it_behaves_like 'balanceable'
  it_behaves_like 'after_create_balance'
end
