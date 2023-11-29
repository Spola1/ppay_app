# frozen_string_literal: true

module Staff
  module Management
    class AdvertisementsController < Staff::BaseController
      before_action :find_advertisement, only: %i[show edit update destroy]

      def index
        @advertisements = if filtering_params.present? &&
                             (filtering_params[:period].present? ||
                            filtering_params[:created_from].present? ||
                            filtering_params[:created_to].present?)
                            Advertisement.time_filters(filtering_params)
                          else
                            Advertisement.filter_by(filtering_params)
                          end
        @pagy, @advertisements = pagy(@advertisements.order(archived_at: :desc, conversion: :asc, status: :desc))
        @advertisements = @advertisements.decorate
      end

      def show; end

      def edit; end

      def update
        @advertisement.assign_attributes(advertisement_params)

        if @advertisement.save
          redirect_to advertisements_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @advertisement.update!(status: false) && @advertisement.archive!
          redirect_to advertisements_path, notice: 'Объявление успешно удалено'
        else
          redirect_to advertisements_path, alert: 'Ошибка удаления объявления'
        end
      end

      private

      def find_advertisement
        @advertisement = Advertisement.find(params[:id]).decorate
      end

      def advertisement_params
        params.require(:advertisement).permit(
          :id, :direction, :national_currency, :cryptocurrency, :payment_system,
          :payment_system_type, :min_summ, :max_summ, :card_number, :autoacceptance,
          :comment, :operator_contact, :exchange_rate_type, :exchange_rate_source,
          :percent, :min_fix_price, :status, :hidden, :account_id, :simbank_auto_confirmation,
          :imei, :phone, :imsi, :simbank_card_number, :sbp_phone_number, :card_owner_name,
          :telegram_phone, :save_incoming_requests_history, :daily_usdt_limit
        )
      end

      def filtering_params
        params[:advertisement_filters]&.slice(:card_number, :status, :national_currency,
                                              :direction, :payment_system,
                                              :processer, :card_owner_name,
                                              :simbank_card_number, :period,
                                              :created_from, :created_to)
      end
    end
  end
end
