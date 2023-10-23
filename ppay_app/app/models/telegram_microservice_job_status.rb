# frozen_string_literal: true

class TelegramMicroserviceJobStatus < ApplicationRecord
  validates :status, presence: true

  def self.fetch_and_create(user)
    status = fetch_status(user)
    create(user_id: user, status:)
  end

  def self.fetch_status(user_id)
    phone_number = Processer.find(user_id).telegram_applications.last.phone_number

    response = HTTParty.get("#{ENV.fetch('TA_PROTOCOL')}://#{ENV.fetch('TA_ADDRESS')}#{ENV.fetch('TA_PORT',
                                                                                                 nil)}/#{ENV.fetch('TA_PATH')}/#{ENV.fetch('TA_CHECK_JOB_PATH')}/#{phone_number}")

    JSON.parse(response.body)['status']
  rescue StandardError => e
    Rails.logger.error("Error fetching job status: #{e.message}")
    'Error'
  end
end
