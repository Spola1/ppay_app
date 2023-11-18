# frozen_string_literal: true

module IncomingRequests
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter_by_created_from, lambda { |created_from|
        where('incoming_requests.created_at >= ?', created_from.in_time_zone.beginning_of_day)
      }

      scope :filter_by_created_to, lambda { |created_to|
        where('incoming_requests.created_at <= ?', created_to.in_time_zone.end_of_day)
      }

      scope :filter_by_national_currency, lambda { |currency|
        joins(:payment).where(payments: { national_currency: currency })
      }

      scope :filter_by_national_currency_amount_from, lambda { |amount|
        joins(:payment).where('payments.national_currency_amount >= ?', amount)
      }

      scope :filter_by_national_currency_amount_to, lambda { |amount|
        joins(:payment).where('payments.national_currency_amount <= ?', amount)
      }

      scope :filter_by_uuid, lambda { |uuid|
        joins(:payment).where(payments: { uuid: })
      }

      scope :filter_by_id, lambda { |id|
        joins(:payment).where(payments: { id: })
      }

      scope :filter_by_card_number, lambda { |card_number|
        joins(payment: :advertisement)
          .where('advertisements.card_number ILIKE :card_number OR payments.card_number ILIKE :card_number',
                 card_number: "%#{card_number}%")
      }

      scope :filter_by_advertisement_id, lambda { |advertisement_id|
        joins(:payment).where(payments: { advertisement_id: })
      }

      scope :filter_by_processer, lambda { |processer|
        processer_id = Processer.find_by(nickname: processer)
        joins(payment: { advertisement: :processer }).where(users: { id: processer_id })
      }

      scope :filter_by_status, lambda { |status|
        case status
        when 'success'
          joins(:payment).where.not(payments: { id: nil })
        when 'canceled'
          left_outer_joins(:payment).where(payments: { id: nil })
        else
          all
        end
      }
    end
  end
end