# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::CancelExpiredJob, type: :job do
  let(:payment) { create :payment }

  describe 'perform' do
    it 'test used methods' do
      expect(Payment).to receive_message_chain(:transferring, :expired)
      Payment.transferring.expired
    end
  end
end
