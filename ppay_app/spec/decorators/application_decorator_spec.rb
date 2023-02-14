# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationDecorator do
  let(:payment) { create :payment }
  describe '#formatted_created_at' do
    it 'Should return the correct created_at format' do
      expect(payment.decorate.formatted_created_at.to_i).to be_within(1.second).of Time.now.strftime('%Y-%m-%d %H:%M').to_i
    end
  end
end
