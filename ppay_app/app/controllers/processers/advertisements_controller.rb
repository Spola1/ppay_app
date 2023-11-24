# frozen_string_literal: true

module Processers
  class AdvertisementsController < Staff::BaseController
    before_action :find_advertisement, only: %i[show edit update destroy]
    before_action :find_advertisement_for_copy, only: %i[new]

    def index
      @pagy, @advertisements = pagy(current_user.advertisements
                                                .filter_by(filtering_params)
                                                .order(archived_at: :desc, status: :desc, conversion: :asc))
      @advertisements = @advertisements.decorate
    end

    def flow
      @advertisements = current_user.advertisements
    end

    def show; end

    def new
      @advertisement = current_user.advertisements.new(@advertisement&.attributes)
    end

    def edit; end

    def create
      @advertisement = current_user.advertisements.new(advertisement_params)
      @advertisement.processer = current_user

      if @advertisement.save
        redirect_to @advertisement
      else
        render :new, status: :unprocessable_entity
      end
    end

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

    def activate_all
      current_user.advertisements.where(status: false).update(status: true)

      redirect_to advertisements_path
    end

    def deactivate_all
      current_user.advertisements.where(status: true).update(status: false)

      redirect_to advertisements_path
    end

    private

    def find_advertisement
      @advertisement = current_user.advertisements.find(params[:id]).decorate
    end

    def find_advertisement_for_copy
      @advertisement = current_user.advertisements.find_by_id(params[:id])
    end

    def advertisement_params
      params.require(:advertisement).permit(:id, :direction, :national_currency, :cryptocurrency, :payment_system,
                                            :payment_system_type, :min_summ, :max_summ, :card_number, :payment_link,
                                            :autoacceptance, :comment, :operator_contact, :exchange_rate_type,
                                            :exchange_rate_source, :percent, :min_fix_price, :status, :hidden,
                                            :account_id, :simbank_auto_confirmation, :imei, :phone, :imsi,
                                            :simbank_card_number, :simbank_sender, :sbp_phone_number, :card_owner_name,
                                            :telegram_phone, :save_incoming_requests_history, :daily_usdt_limit)
    end

    def filtering_params
      params[:advertisement_filters]&.slice(:card_number, :status, :national_currency, :direction, :payment_system,
                                            :processer)
    end
  end
end
