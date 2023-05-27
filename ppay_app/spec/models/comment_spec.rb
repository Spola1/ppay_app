# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { is_expected.to belong_to(:user).optional(true) }
  it { is_expected.to belong_to(:commentable) }

  pending "add some examples to (or delete) #{__FILE__}"
end
