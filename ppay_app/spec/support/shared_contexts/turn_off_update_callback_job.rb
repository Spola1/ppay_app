# frozen_string_literal: true

shared_context 'turn off UpdateCallbackJob' do
  before do
    allow(Payments::UpdateCallbackJob).to receive(:perform_async)
  end
end
