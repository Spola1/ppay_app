require 'rails_helper'

feature 'Processor can see new withdrawal', type: :feature do
  context 'processer have advertisement for withdrawal' do
    let!(:rate_snapshot) { create(:rate_snapshot) }
    let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:payment) { create(:payment, :withdrawal, :transferring, advertisement: advertisement) }

    before do
      visit '/users/sign_in'
      fill_in 'Email', with: advertisement.processer.email
      fill_in 'Пароль', with: advertisement.processer.password
      click_on 'Вход'
    end

    scenario 'processer signs in and see new payment' do
      expect(page).to have_content('Ждут ваших действий')
      expect(advertisement.processer.payments.size).to eq(1)
      expect(advertisement.processer.payments.first.payment_status).to eq('transferring')
    end
  end

  context 'processer has no advertisement for withdrawal' do
    let!(:rate_snapshot) { create(:rate_snapshot) }
    let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'AlfaBank') }
    let!(:payment) { create(:payment, :withdrawal, :transferring) }

    before do
      visit '/users/sign_in'
      fill_in 'Email', with: advertisement.processer.email
      fill_in 'Пароль', with: advertisement.processer.password
      click_on 'Вход'
    end

    scenario 'processer signs in and not see new payment' do
      expect(page).not_to have_content('Ждут ваших действий')
      expect(advertisement.processer.payments.size).to eq(0)
    end
  end
end
