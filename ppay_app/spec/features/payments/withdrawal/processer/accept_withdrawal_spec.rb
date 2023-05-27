# frozen_string_literal: true

require 'rails_helper'

feature 'Processor can confirm withdrawal', type: :feature do
  before do
    visit '/users/sign_in'
    fill_in 'Email', with: advertisement.processer.email
    fill_in 'Пароль', with: advertisement.processer.password
    click_on 'Вход'
    visit "/payments/withdrawals/#{payment.uuid}"
  end

  context 'merchant check required true' do
    let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:payment) { create(:payment, :withdrawal, :transferring, advertisement:) }
    let(:image_path) { Rails.root.join('spec', 'fixtures', 'test_files', 'sample.jpeg') }

    scenario 'processer logs in, opens a new withdrawal and try to
      confirms it without screenshot' do
      expect(page).to have_content('Данные платежа')
      expect(page).to have_button('Оплата завершена')

      click_on 'Оплата завершена'

      expect(page).to have_content('Скриншот не загружен')

      payment.reload

      expect(payment.payment_status).to eq('transferring')
    end

    scenario 'processer logs in, opens a new withdrawal and try to confirms it with screenshot' do
      expect(page).to have_content('Данные платежа')
      expect(page).to have_button('Оплата завершена')

      attach_file 'withdrawal_image', image_path

      click_on 'Оплата завершена'

      payment.reload

      expect(payment.payment_status).to eq('confirming')
    end
  end

  context 'merchant check required false' do
    let!(:merchant) { create(:merchant, check_required: false) }
    let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:payment) do
      create(:payment, :withdrawal, :transferring, advertisement:,
                                                   merchant:)
    end

    scenario 'processer logs in, opens a new withdrawal and try to confirms it' do
      expect(page).to have_content('Данные платежа')
      expect(page).to have_button('Оплата завершена')

      click_on 'Оплата завершена'

      payment.reload

      expect(payment.payment_status).to eq('confirming')
    end
  end
end
