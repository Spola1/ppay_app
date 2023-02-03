# frozen_string_literal: true

module Merchants
  class Staff::BaseController < ApplicationController
    before_action :authenticate_user!
  end
end
