# frozen_string_literal: true

module Staff
  module Management
    class AdvertisementsController < Staff::BaseController
      before_action :find_advertisement, only: %i[show edit update destroy]

      def index
        @pagy, @advertisements = pagy(Advertisement.order(created_at: :desc).all)
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
        if @advertisement.delete
          redirect_to advertisements_path, notice: 'Объявление успешно удалено'
        else
          redirect_to advertisements_path, alert: 'Ошибка удаления объявления'
        end
      end

      private

      def find_advertisement
        @advertisement = Advertisement.find(params[:id])
      end

      def advertisement_params
        params.require(:advertisement).permit(
          :id, :direction, :national_currency, :cryptocurrency, :payment_system,
          :payment_system_type, :min_summ, :max_summ, :card_number, :autoacceptance,
          :comment, :operator_contact, :exchange_rate_type, :exchange_rate_source,
          :percent, :min_fix_price, :status, :hidden, :account_id, :simbank_auto_confirmation, 
          :imei, :phone, :imsi, :simbank_card_number
        )
      end
    end
  end
end
