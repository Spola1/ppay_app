require 'rails_helper'

RSpec.describe PaymentsHelper, type: :helper do
  describe '#support_payment_statuses_collection' do
    it 'returns a collection of possible payment statuses' do
      expect(helper.support_payment_statuses_collection).to eq([
        [state_translation(:transferring), :transferring],
        [state_translation(:confirming), :confirming],
        [state_translation(:completed), :completed],
        [state_translation(:cancelled), :cancelled]
      ])
    end
  end
end