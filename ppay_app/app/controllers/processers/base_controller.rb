# frozen_string_literal: true

module Processers
  class Staff::BaseController < ApplicationController
    before_action :authenticate_user!
  end
end
