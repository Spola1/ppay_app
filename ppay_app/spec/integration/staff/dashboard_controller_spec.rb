# frozen_string_literal: true

require 'rails_helper'

describe 'dashboard', type: :request do
  let!(:admin) { create :user, :admin }
  let!(:payment) { create :payment }

  before do
    login_as admin
  end

  it 'show stats' do
    get dashboard_path
    expect(response).to have_http_status(200)
    expect(response.body).to include('Общая статистика')
  end
end
