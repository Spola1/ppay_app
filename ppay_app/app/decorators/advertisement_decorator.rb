class AdvertisementDecorator < ApplicationDecorator
  delegate_all

  def formatted_created_at
    formatted_date(created_at)
  end
end
