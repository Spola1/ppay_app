# frozen_string_literal: true

module Payments
  class UpdateCallbackJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['payments_update_callback']

    def perform(payment_id)
      payment = Payment.find(payment_id)

      Payments::UpdateCallbackService.call(payment)
    end
  end
end
