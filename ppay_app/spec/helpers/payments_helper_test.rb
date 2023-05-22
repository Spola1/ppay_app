# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentsHelper, type: :helper do
  describe '#support_payment_statuses_collection' do
    let(:expected_collection) do
      [['Перевод денег', :transferring], ['Подтверждение перевода', :confirming],
       ['Успешно завершён', :completed], ['Отменён', :cancelled]]
    end

    it 'returns an array of arrays with status translations and symbols' do
      expect(helper.support_payment_statuses_collection).to eq(expected_collection)
    end
  end

  describe '#payment_status_class' do
    let(:payment_completed) { create(:payment, :completed) }
    let(:payment_cancelled) { create(:payment, :cancelled) }
    let(:payment_processing) { create(:payment, :processer_search) }

    it 'returns "completed-status" for completed payment' do
      expect(helper.payment_status_class(payment_completed)).to eq('completed-status')
    end

    it 'returns "cancelled-status" for cancelled payment' do
      expect(helper.payment_status_class(payment_cancelled)).to eq('cancelled-status')
    end

    it 'returns "processing-status" for processing payment' do
      expect(helper.payment_status_class(payment_processing)).to eq('processing-status')
    end
  end
end
