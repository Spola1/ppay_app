# frozen_string_literal: true

module Staff
  class Staff::BaseController < ApplicationController
    before_action :authenticate_user!
  end
end
