module Api
  module V1
    class MerchantMethodsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!
      before_action :set_filters

      def index
        sql_request = build_sql_request

        result_array = sql_request.group_by(&:merchant_method_id).values.map do |commissions|
          build_answer(commissions)
        end

        render json: result_array
      end

      private

      def set_filters
        @currency = params[:currency]
        @payment_system = params[:payment_system]
      end

      def build_sql_request
        base_request = current_bearer.commissions
          .joins(merchant_method: { payment_system: :national_currency })
          .select(
            'commissions.id, commissions.commission_type, commissions.commission, ' \
            'commissions.merchant_method_id AS merchant_method_id, merchant_methods.direction, ' \
            'payment_systems.name AS payment_system_name, national_currencies.name AS national_currency_name'
          )
          .order(commission_type: :asc, 'payment_systems.id': :asc,
            'payment_systems.national_currency_id': :asc, direction: :asc)

        base_request = base_request.where(payment_systems: { name: @payment_system }) if @payment_system
        base_request = base_request.where(national_currencies: { name: @currency }) if @currency

        base_request
      end

      def build_answer(commissions)
        [
          { 'Payment method' => commissions.first.payment_system_name },
          { 'Currency' => commissions.first.national_currency_name },
          { 'Payment type' => commissions.first.direction },
          { 'Total percentage' => calculate_total_commission(commissions) }
        ]
      end

      def calculate_total_commission(commissions)
        commissions.select { |commission| ['agent', 'other'].include?(commission.commission_type) }.sum(&:commission)
      end
    end
  end
end
