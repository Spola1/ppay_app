# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CryptoWallet, type: :model do
  it { is_expected.to belong_to(:user).optional(true) }
end
