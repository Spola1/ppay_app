# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramNotificationService, type: :service do
  let(:payment) { create :payment, :deposit, :confirming }
  let(:uuid) { payment.uuid }
  let(:national_currency_amount) { 100 }
  let(:card_number) { '1234567890' }
  let(:username) { 'test_user' }
  let(:chat_id) { 123 }

  subject { described_class.new(uuid, national_currency_amount, card_number) }

  describe '#get_user_id' do
    it 'returns user ID if username matches' do
      json_response = {
        'result' => [
          {
            'message' => {
              'chat' => {
                'id' => chat_id,
                'username' => username
              }
            }
          }
        ]
      }

      allow(Net::HTTP).to receive(:get).and_return(json_response.to_json)

      expect(subject.get_user_id(username)).to eq(chat_id)
    end

    it 'returns nil if username does not match' do
      json_response = {
        'result' => [
          {
            'message' => {
              'chat' => {
                'id' => chat_id,
                'username' => 'another_user'
              }
            }
          }
        ]
      }

      allow(Net::HTTP).to receive(:get).and_return(json_response.to_json)

      expect(subject.get_user_id(username)).to be_nil
    end
  end
end
