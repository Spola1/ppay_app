# frozen_string_literal: true

module Admins
  class MasksController < Staff::BaseController
    before_action :find_mask, only: %i[edit update destroy]

    def index
      @masks = Mask.all
    end

    def new
      @mask = Mask.new
    end

    def create
      if @mask.save
        redirect_to masks_path, notice: 'Маска успешно создана.'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @mask.update(mask_params)
        redirect_to masks_path, notice: 'Маска успешно обновлена.'
      else
        render :edit
      end
    end

    def destroy
      @mask.destroy
      redirect_to masks_path, notice: 'Маска успешно удалена.'
    end

    private

    def find_mask
      @mask = Mask.find(params[:id])
    end

    def mask_params
      params.require(:mask).permit(:name, :sms_mask, :push_mask)
    end
  end
end
