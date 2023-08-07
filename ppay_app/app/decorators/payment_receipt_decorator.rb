# frozen_string_literal: true

class PaymentReceiptDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def image_url
    rails_blob_url(image)
  end
end
