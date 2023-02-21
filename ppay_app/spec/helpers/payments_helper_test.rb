require 'rails_helper'

RSpec.describe PaymentsHelper, type: :helper do
  describe "#support_payment_statuses_collection" do
    it "returns an array of arrays with status translations and symbols" do
      expected_collection = [
        ["Перевод денег", :transferring],
        ["Подтверждение перевода", :confirming],
        ["Успешно завершён", :completed],
        ["Отменён", :cancelled]
      ]
      expect(helper.support_payment_statuses_collection).to eq(expected_collection)
    end
  end
end