# frozen_string_literal: true

module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!

    private

    def create_visit
      @payment.visits.create(
        ip: request.remote_ip,
        user_agent: request.user_agent,
        cookie: request.cookies.to_h.to_s,
        url: request.original_url,
        method: request.method,
        headers: request.headers.to_h.to_s,
        query_parameters: request.query_parameters.to_json,
        request_parameters: request.request_parameters.to_json,
        session: request.session.to_json,
        env: request.env.to_s,
        ssl: request.ssl?
      )
    end

    def mark_messages_as_read(messages)
      message_ids = messages.map(&:id)
      MessageReadStatus.where(user: current_user, message_id: message_ids).update_all(read: true)
    end
  end
end
