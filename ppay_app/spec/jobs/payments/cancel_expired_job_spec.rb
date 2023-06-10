# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::CancelExpiredJob, type: :job do
  describe '#perform' do
    let!(:payment) { create(:payment, :transferring) }

    before do
      allow(Payment).to receive_message_chain(:transferring, :expired).and_return(Payment.where(id: payment.id))
    end

    it 'cancels expired payments and setup cancellation reason to time expired' do
      described_class.new.perform

      payment.reload

      expect(payment.payment_status).to eq('cancelled')
      expect(payment.cancellation_reason).to eq("time_expired")
    end

    it 'logs the cancelled payment' do
      payment.cancel!

      expect { described_class.new.perform }.to output(/Платёж #{payment.uuid} отменён/).to_stdout
    end
  end
end
