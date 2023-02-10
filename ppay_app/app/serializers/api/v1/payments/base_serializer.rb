# frozen_string_literal: true

module Api
  module V1
    module Payments
      class BaseSerializer < ActiveModel::Serializer
        attributes :uuid
      end
    end
  end
end
