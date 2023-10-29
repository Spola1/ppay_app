# frozen_string_literal: true

module IncomingRequestsHelper
  def incoming_request_filters_params(key)
    params[:incoming_request_filters][key] if params[:incoming_request_filters]
  end

  def incoming_request_filters_partial(user)
    if user.processer?
      'shared/staff/incoming_requests/filters'
    else
      'shared/staff/management/incoming_requests/filters'
    end
  end
end
