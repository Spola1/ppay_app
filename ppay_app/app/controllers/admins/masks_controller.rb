# frozen_string_literal: true

module Admins
  class MasksController < Staff::BaseController
    before_action :set_mask, only: %i[show edit update destroy]

    def index
      @masks = Mask.all
    end

    def show; end

    def new
      @mask = Mask.new
    end

    def edit; end

    def create
      @mask = Mask.create(mask_params)

      if @mask.save
        redirect_to mask_path(@mask), notice: 'Маска создана.'
      else
        render :new
      end
    end

    def update
      if @mask.update(mask_params)
        redirect_to mask_path(@mask), notice: 'Маска успешно обновлена.'
      else
        render :edit
      end
    end

    def destroy
      @mask.destroy
      redirect_to masks_path, notice: 'Маска удалена.'
    end

    private

    def set_mask
      @mask = Mask.find(params[:id])
    end

    def mask_params
      params.require(:mask).permit(:sender, :regexp_type, :regexp)
    end
  end
end
