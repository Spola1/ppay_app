require 'rails_helper'
require 'models/concerns/balanceable'
require 'models/concerns/after_create_balance'

RSpec.describe User, type: :model do
  it_behaves_like 'balanceable'
  it_behaves_like 'after_create_balance'
  it { is_expected.to have_many(:api_keys) }
end
