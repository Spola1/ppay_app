require 'rails_helper'

RSpec.describe Payments::SearchProcesser::Base, type: :job do
  let(:payment) { create :payment, :withdrawal }

  describe 'perform' do
    it 'return reload advertisement' do
      expect(payment).to receive_message_chain(:reload, :advertisement)
      payment.reload.advertisement
    end

    it 'return reload processer search' do
      expect(payment).to receive_message_chain(:reload, :processer_search?)
      payment.reload.processer_search?
    end
  end
end
