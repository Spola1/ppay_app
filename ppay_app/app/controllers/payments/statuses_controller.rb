# frozen_string_literal: true

module Payments
  class StatusesController < PaymentsController
    include ::Payments::Statuses::Updateable

    private

    def payment_params
      {}
    end
  end
end
