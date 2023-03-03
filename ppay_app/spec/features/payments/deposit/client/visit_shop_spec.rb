# frozen_string_literal: true

require 'rails_helper'

feature 'Client can come back to shop after deposit or after cancelled deposit', type: :feature do
  before do
    visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
  end

  context 'deposit status is completed' do
    let!(:payment) { create(:payment, :deposit, :completed) }

    scenario 'client try to come back to shop' do
      expect(page).to have_content('Успешно!')
      expect(page).to have_content('Платеж выполнен!')
      expect(page).to have_content("uuid: #{payment.uuid}")
      expect(page).to have_link('вернуться в магазин', href: payment.redirect_url.to_s)

      click_on 'вернуться в магазин'

      expect(page).to have_content('Email')
      expect(page).to have_content('Пароль')
      expect(page).to have_content('Запомнить меня')
    end
  end

  context 'deposit status is cancelled' do
    let!(:payment) { create(:payment, :deposit, :cancelled) }

    scenario 'client try to come back to shop' do
      expect(page).to have_content('Платеж отменён !')
      expect(page).to have_content("uuid: #{payment.uuid}")
      expect(page).to have_link('вернуться в магазин', href: payment.redirect_url.to_s)

      click_on 'вернуться в магазин'

      expect(page).to have_content('Email')
      expect(page).to have_content('Пароль')
      expect(page).to have_content('Запомнить меня')
    end
  end
end
