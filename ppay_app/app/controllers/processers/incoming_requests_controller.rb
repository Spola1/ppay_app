# frozen_string_literal: true

module Processers
  class IncomingRequestsController < Staff::IncomingRequestsController
    def index
      @pagy, @incoming_requests = pagy(filtered_incoming_requests)
      @incoming_requests = @incoming_requests.order(created_at: :desc).decorate
    end

    private

    def filtered_incoming_requests
      IncomingRequest.filter_by(filtering_params)
                     .joins(payment: { advertisement: :processer })
                     .where(users: { id: current_user.id })
    end
  end
end