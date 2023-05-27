# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CryptoWallet, type: :model do
  it { is_expected.to belong_to(:user).optional(true) }

  pending "add some examples to (or delete) #{__FILE__}"
end
