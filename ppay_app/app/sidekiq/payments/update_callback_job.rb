# frozen_string_literal: true

module Payments
  class UpdateCallbackJob
    include Sidekiq::Job
    sidekiq_options queue: 'critical', tags: ['update_callback']

    def perform(*args)
      Payments::UpdateCallback.call(*args)
    end
  end
end
