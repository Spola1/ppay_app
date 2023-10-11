# frozen_string_literal: true

module IncomingRequestsHelper
  def incoming_request_filters_params(key)
    params[:incoming_request_filters][key] if params[:incoming_request_filters]
  end
end
