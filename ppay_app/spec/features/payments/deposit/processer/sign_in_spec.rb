require 'rails_helper'

feature 'Processor can log in', type: :feature do
  let!(:processer) { create(:processer) }

  before do
    visit '/users/sign_in'
  end

  scenario 'registered processer tries to sign in' do
    fill_in 'Email', with: processer.email
    fill_in 'Пароль', with: processer.password

    click_on 'Вход'

    expect(page).to have_content('Вход в систему выполнен.')
    expect(page).to have_content("Баланс: #{processer.balance.amount}")
  end

  scenario 'unregistered processer tries to sign in' do
    fill_in 'Email', with: 'test@test.test'
    fill_in 'Пароль', with: 'test'

    click_on 'Вход'

    expect(page).to have_content('Email')
    expect(page).to have_content('Пароль')
  end
end
