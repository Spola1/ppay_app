# frozen_string_literal: true

module Processers
  class AdvertisementsController < BaseController
    def index
      @advertisements = current_user.advertisements.decorate
    end

    def show
      @advertisement = current_user.advertisements.find(params[:id])
    end

    def new
      @advertisement = current_user.advertisements.new
    end

    def edit
      @advertisement = current_user.advertisements.find(params[:id])
    end

    def create
      @advertisement = current_user.advertisements.new(advertisement_params)
      @advertisement.processer = current_user
      if @advertisement.save
        redirect_to @advertisement
      else
        # error
      end
    end

    def update
      @advertisement = current_user.advertisements.find(params[:id])
      @advertisement.update(advertisement_params)
      redirect_to advertisements_path if @advertisement.errors.empty?
    end

    def destroy; end

    private

    def advertisement_params
      params.require(:advertisement).permit(:id, :direction, :national_currency, :cryptocurrency, :payment_system,
                                            :payment_system_type, :min_summ, :max_summ, :card_number, :autoacceptance,
                                            :comment, :operator_contact, :exchange_rate_type, :exchange_rate_source,
                                            :percent, :min_fix_price, :status, :hidden, :account_id)
    end
  end
end
