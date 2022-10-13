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
        "#{ model_class }Serializer".classify.constantize
      end

      def serialized_object
        serializer.new(@object.reload.decorate)
      end
    end
  end
end
