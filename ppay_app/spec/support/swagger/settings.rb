# frozen_string_literal: true

V1_SCHEMAS = %w[payments/create].freeze

V1_SCHEMAS.each do |path|
  require_relative "schemas/v1/#{path}"
end

module Swagger
  class Settings
    include Singleton

    def v1_schemas
      V1_SCHEMAS.each_with_object({}) do |path, obj|
        obj.merge!(build_schema(path))
      end
    end

    private

    def build_schema(path)
      "swagger/schemas/v1/#{path}".camelize.constantize.public_send('schemas')
    end
  end
end
