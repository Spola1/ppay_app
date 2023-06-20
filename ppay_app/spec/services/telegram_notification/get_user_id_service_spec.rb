require 'rails_helper'

RSpec.describe TelegramNotification::GetUserIdService do
  let(:service) { described_class.new('example_username') }

  describe '#get_user_id' do
    context 'when the user is found' do
      it 'returns the user ID for the provided telegram username' do
        updates = [
          { 'message' => { 'chat' => { 'id' => 123, 'username' => 'example_username' } } },
          { 'message' => { 'chat' => { 'id' => 456, 'username' => 'another_username' } } }
        ]

        stub_request(:get, TelegramNotification::BaseService::API_URL)
          .to_return(body: { 'result' => updates }.to_json)

        user_id = service.get_user_id('example_username')
        expect(user_id).to eq(123)
      end
    end

    context 'when the user is not found' do
      it 'returns nil' do
        updates = [
          { 'message' => { 'chat' => { 'id' => 123, 'username' => 'another_username' } } },
          { 'message' => { 'chat' => { 'id' => 456, 'username' => 'yet_another_username' } } }
        ]

        stub_request(:get, TelegramNotification::BaseService::API_URL)
          .to_return(body: { 'result' => updates }.to_json)

        user_id = service.get_user_id('example_username')
        expect(user_id).to be_nil
      end
    end
  end
end