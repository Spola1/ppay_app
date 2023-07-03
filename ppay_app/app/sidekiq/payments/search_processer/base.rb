# frozen_string_literal: true

module Payments
  module SearchProcesser
    class Base
      include Sidekiq::Job
      sidekiq_options queue: 'high', tags: ['search_processer']

      attr_reader :payment

      def perform(payment_id)
        loop do
          result = search_processer.call(payment_id:)

          if result.success?
            puts 'найден'
            break
          else
            puts 'не найден'

            break unless result.processer_search

            sleep 0.5
          end
        end
      end

      private

      def search_processer
        self.class.name.gsub('Job', 'Interactor').constantize
      end
    end
  end
end
