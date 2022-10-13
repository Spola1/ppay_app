# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @advertisements = current_processer.advertisements.decorate
  end

  def show
    @advertisement = current_processer.advertisements.find(params[:id])
  end

  def new
    @advertisement = current_processer.advertisements.new
  end

  def edit
    @advertisement = current_processer.advertisements.find(params[:id])
  end

  def create
    @advertisement = current_processer.advertisements.new(advertisement_params)
    @advertisement.processer = current_processer
    if @advertisement.save
      redirect_to @advertisement
    else
      # error
    end
  end

  def update
    @advertisement = current_processer.advertisements.find(params[:id])
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
