# frozen_string_literal: true

require 'rails_helper'

feature 'Support can add comments to balance request' do
  let!(:support) { create(:support) }
  let!(:balance_request) { create(:balance_request, :withdraw) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: support.email
    fill_in 'Пароль', with: support.password
    click_on 'Вход'
    visit "/balance_requests/#{balance_request.id}"
  end

  scenario 'support adds comment to balance request' do
    click_on 'Подтвердить или отказать ->'

    fill_in 'balance_request_short_comment', with: 'My new comment'

    click_on 'Сохранить'

    expect(page).to have_content 'My new comment'
    expect(balance_request.status).to eq('processing')
  end
end
