# frozen_string_literal: true

class ApplicationController < ActionController::Base

  private

  def current_processer
    current_user.becomes(Processer)
  end

  def model_class
    self.class.name.demodulize.gsub('Controller', '').singularize
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
