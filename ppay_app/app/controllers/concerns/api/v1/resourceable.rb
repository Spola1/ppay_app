# frozen_string_literal: true

module Api
  module V1
    module Resourceable
      extend ActiveSupport::Concern

      private

      def model_class
        self.class.name.demodulize.gsub('Controller', '').singularize
      end

      def model_class_plural
        model_class.underscore.pluralize
      end

      def serializer
        "#{model_class}Serializer".classify.constantize
      end

      def serialized_object
        serializer.new(@object.reload.decorate)
      end

      def render_object_errors(object)
        errors = object.errors.map do |error_object|
          ::JsonApi::Error.new(
            code: 422, title: error_object.attribute,
            detail: Array(error_object.message).join(', ')
          ).to_hash
        end

        render json: { errors: }, status: :unprocessable_entity
      end
    end
  end
end
