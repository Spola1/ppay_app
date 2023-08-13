# frozen_string_literal: true

require 'rails_helper'

feature 'Support can restore cancelled deposit', type: :feature do
  let!(:support) { create(:support) }
  let!(:deposit) { create(:payment, :deposit, :cancelled, :with_cancelled_transactions) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: support.email
    fill_in 'Пароль', with: support.password
    click_on 'Вход'
    visit "/payments/deposits/#{deposit.uuid}"
  end

  scenario 'support tries to restore cancelled deposit' do
    expect(page).to have_button('Подтвердить платёж')

    click_on 'Подтвердить платёж'

    deposit.reload

    expect(deposit.completed?).to eq true
  end
end
