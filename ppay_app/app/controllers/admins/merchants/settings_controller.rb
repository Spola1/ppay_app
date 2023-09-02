# frozen_string_literal: true

module Admins
  module Merchants
    class SettingsController < BaseController
      def show
        set_commissions
      end

      def update
        @merchant.update(settings_params.except(:commissions))

        grouped_commission = settings_params[:commissions]
                             .to_h.map { { id: _1, commission: _2 } }
                             .index_by { _1[:id] }

        Commission.update(grouped_commission.keys, grouped_commission.values)

        redirect_back fallback_location: merchant_settings_path(@merchant)
      end

      private

      def set_commissions
        @commissions =
          @merchant.commissions
                   .joins(merchant_method: { payment_system: :national_currency })
                   .select(
                     'commissions.id, commissions.commission_type, commissions.commission, ' \
                     'commissions.merchant_method_id AS merchant_method_id, merchant_methods.direction, ' \
                     'payment_systems.name AS payment_system_name, national_currencies.name AS national_currency_name'
                   )
                   .order(commission_type: :asc, 'payment_systems.id': :asc,
                          'payment_systems.national_currency_id': :asc, direction: :asc)
                   .group_by(&:merchant_method_id)
      end

      def settings_params
        params.require(:merchant)
              .permit(:nickname, :name, :check_required, :unique_amount, :any_bank, :account_number_required,
                      :account_number_title, :account_number_placeholder, :chat_enabled, :agent_id,
                      :equal_amount_payments_limit, :short_freeze_days, :long_freeze_days,
                      :long_freeze_percentage, :balance_freeze_type, :fee_percentage, commissions: {})
      end
    end
  end
end
