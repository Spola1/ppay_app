# frozen_string_literal: true

module Advertisements
  class EnableAdvertisementStatusJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['enable_advertisement_status']

    def perform
      Advertisement.for_enable_status.update_all(status: true, block_reason: nil)
    end
  end
end
