require 'rails_helper'

RSpec.describe PaymentsHelper, type: :helper do
  describe "#support_payment_statuses_collection" do
    let(:expected_collection) { [["Перевод денег", :transferring], ["Подтверждение перевода", :confirming],
                                   ["Успешно завершён", :completed], ["Отменён", :cancelled]] }

    it "returns an array of arrays with status translations and symbols" do
      expect(helper.support_payment_statuses_collection).to eq(expected_collection)
    end
  end
end