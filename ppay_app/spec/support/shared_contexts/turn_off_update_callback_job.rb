# frozen_string_literal: true

shared_context 'turn off some jobs' do
  before do
    allow(Payments::UpdateCallbackJob).to receive(:perform_async)
    allow(BalanceRequests::Admins::NewBalanceRequestNotificationJob).to receive(:perform_async)
  end
end
