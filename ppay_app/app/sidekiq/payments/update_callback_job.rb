# frozen_string_literal: true

module Payments
  class UpdateCallbackJob
    include Sidekiq::Job
    sidekiq_options queue: 'critical', tags: ['update_callback']

    def perform(payment_id)
      payment = Payment.find(payment_id)

      Payments::UpdateCallback.call(payment)
    end
  end
end
