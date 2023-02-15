# frozen_string_literal: true

module Api
  module V1
    module Payments
      module Create
        class BaseSerializer
          include JSONAPI::Serializer

          attributes :uuid, :url
        end
      end
    end
  end
end
