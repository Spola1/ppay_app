# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationDecorator do
  let(:payment) { create :payment, created_at: 'Fri, 17 Feb 2023 22:53:22.595096000 MSK +03:00' }

  describe '#formatted_created_at' do
    it 'Should return the correct created_at format' do
      expect(payment.decorate.formatted_created_at).to eq('2023-02-17 22:53')
    end
  end
end
