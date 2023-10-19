# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::CancelExpiredJob, type: :job do
  describe '#perform' do
    subject { described_class.new.perform }

    let!(:payment) { create(:payment, :transferring, arbitration:, arbitration_reason:) }
    let(:arbitration) { false }
    let(:arbitration_reason) { nil }

    before { silence_output }
    after { restore_output }

    it { expect { subject }.not_to change { payment.reload.payment_status }.from('transferring') }
    it { expect { subject }.not_to change { payment.reload.cancellation_reason }.from(nil) }
    it { expect { subject }.not_to output(/Платёж #{payment.uuid} отменён/).to_stdout }

    context 'expired payment' do
      before do
        allow(Payment).to receive_message_chain(:transferring, :expired).and_return(Payment.where(id: payment.id))
      end

      it { expect { subject }.to change { payment.reload.payment_status }.from('transferring').to('cancelled') }
      it { expect { subject }.to change { payment.reload.cancellation_reason }.from(nil).to('time_expired') }
      it { expect { subject }.to output("Платёж #{payment.uuid} отменён\n").to_stdout }
    end

    context 'payment in arbitration' do
      let(:arbitration) { true }

      it { expect { subject }.not_to change { payment.reload.arbitration }.from(true) }
      it { expect { subject }.not_to change { payment.reload.payment_status }.from('transferring') }
      it { expect { subject }.not_to change { payment.reload.cancellation_reason }.from(nil) }
      it { expect { subject }.not_to output(/Платёж #{payment.uuid} отменён/).to_stdout }

      context 'with not_paid arbitration reason' do
        let(:arbitration_reason) { :not_paid }

        it { expect { subject }.to change { payment.reload.arbitration }.from(true).to(false) }
        it { expect { subject }.to change { payment.reload.payment_status }.from('transferring').to('cancelled') }
        it { expect { subject }.to change { payment.reload.cancellation_reason }.from(nil).to('not_paid') }
        it { expect { subject }.to output("Платёж #{payment.uuid} отменён\n").to_stdout }
      end
    end

    context 'expired payment in arbitration' do
      before do
        allow(Payment).to receive_message_chain(:transferring, :expired).and_return(Payment.where(id: payment.id))
      end
      let(:arbitration) { true }

      it { expect { subject }.not_to change { payment.reload.arbitration }.from(true) }
      it { expect { subject }.to change { payment.reload.payment_status }.from('transferring').to('cancelled') }
      it { expect { subject }.to change { payment.reload.cancellation_reason }.from(nil).to('time_expired') }
      it { expect { subject }.to output("Платёж #{payment.uuid} отменён\n").to_stdout }

      context 'with not_paid arbitration reason' do
        let(:arbitration_reason) { :not_paid }

        it { expect { subject }.to change { payment.reload.arbitration }.from(true).to(false) }
        it { expect { subject }.to change { payment.reload.payment_status }.from('transferring').to('cancelled') }
        it { expect { subject }.to change { payment.reload.cancellation_reason }.from(nil).to('not_paid') }
        it { expect { subject }.to output(/Платёж #{payment.uuid} отменён/).to_stdout }
      end
    end
  end
end
