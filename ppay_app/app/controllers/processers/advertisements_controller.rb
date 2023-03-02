# frozen_string_literal: true

module Processers
  class AdvertisementsController < Staff::BaseController
    def index
      @pagy, @advertisements = pagy(current_user.advertisements)
      @advertisements = @advertisements.decorate
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
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @advertisement = current_user.advertisements.find(params[:id])
      @advertisement.assign_attributes(advertisement_params)

      if @advertisement.save
        redirect_to advertisements_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy; end

    def activate_all
      @advertisements = current_user.advertisements.where(status: false).update_all(status: true)
      redirect_to advertisements_path
    end
  
    def deactivate_all
      @advertisements = current_user.advertisements.where(status: true).update_all(status: false)
      redirect_to advertisements_path
    end
    
    private

    def advertisement_params
      params.require(:advertisement).permit(:id, :direction, :national_currency, :cryptocurrency, :payment_system,
                                            :payment_system_type, :min_summ, :max_summ, :card_number, :autoacceptance,
                                            :comment, :operator_contact, :exchange_rate_type, :exchange_rate_source,
                                            :percent, :min_fix_price, :status, :hidden, :account_id)
    end
  end
end
