# frozen_string_literal: true

module Admins
  class ProcessersController < Staff::BaseController
    def index
      set_all_processers
    end

    def new
      @processer = Processer.new
    end

    def create
      @processer = Processer.new(processer_params)

      if @processer.save
        redirect_to processer_settings_path(@processer)
      else
        render 'new'
      end
    end

    private

    def set_all_processers
      @pagy, @processers = pagy(Processer.all)
      @processers = @processers.order(created_at: :desc).decorate
    end

    def find_processer
      @processer = Processer.find_by_id(params[:id]).decorate
    end

    def processer_params
      params.require(:processer)
            .permit(:email, :password, :password_confirmation)
            .merge(type: :Processer)
    end
  end
end
