# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::UpdateCallbackService, type: :job do
  let(:payment) { create :payment, :withdrawal }

  describe 'perform' do
    it 'test used methods' do
      expect(Payments::UpdateCallbackService).to receive(:call).with(payment)
      Payments::UpdateCallbackService.call(payment)
    end
  end
end
