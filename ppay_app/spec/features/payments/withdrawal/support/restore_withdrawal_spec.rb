# frozen_string_literal: true

require 'rails_helper'

feature 'Support can restore cancelled withdrawal', type: :feature do
  let!(:support) { create(:support) }
  let!(:payment) { create(:payment, :withdrawal, :cancelled, :with_cancelled_transactions) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: support.email
    fill_in 'Пароль', with: support.password
    click_on 'Вход'
    visit "/payments/withdrawals/#{payment.uuid}"
  end

  scenario 'support tries to restore cancelled deposit' do
    expect(page).to have_button('Подтвердить платёж')

    click_on 'Подтвердить платёж'

    payment.reload

    expect(payment.completed?).to eq true
  end
end
