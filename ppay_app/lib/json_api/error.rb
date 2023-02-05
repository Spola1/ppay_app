# frozen_string_literal: true

module JsonApi
  class Error < StandardError
    attr_accessor :title, :detail, :id, :href, :code, :source, :links, :status, :meta

    def initialize(options = {})
      @title          = options[:title]
      @detail         = options[:detail]
      @id             = options[:id]
      @href           = options[:href]
      @code           = options[:code]
      @source         = options[:source]
      @links          = options[:links]
      @status         = Rack::Utils::SYMBOL_TO_STATUS_CODE[options[:status]].to_s
      @meta           = options[:meta]
      super
    end

    def to_hash
      hash = {}
      instance_variables.each do |var|
        hash[var.to_s.delete('@')] = instance_variable_get(var) if instance_variable_get(var).present?
      end
      hash
    end
  end
end
