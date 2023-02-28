# frozen_string_literal: true

require 'rails_helper'

feature 'Client can completed deposit', type: :feature do
  before do
    visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
  end

  context 'merchant check required true' do 
    let(:image_path) { Rails.root.join('spec', 'fixtures', 'test_files', 'sample.jpeg') }
    let(:advertisement) { create(:advertisement, :deposit, payment_system: 'Tinkoff') }
    let(:payment) { create(:payment, :deposit, :transferring, advertisement: advertisement) }

    scenario 'client try to completed deposit with image' do
      expect(page).to have_content('Добавьте изображение чека:')

      attach_file 'image', image_path

      click_on 'Оплата завершена'

      expect(page).to have_content('Идёт обработка')
      expect(page).to have_content('Ожидайте пожалуйста...')
      expect(page).to have_content("uuid: #{payment.uuid}")

      payment.reload

      expect(payment.payment_status).to eq('confirming')
    end

    scenario 'client try to completed deposit without image' do
      expect(page).to have_content('Добавьте изображение чека:')

      click_on 'Оплата завершена'

      expect(page).to have_content('Скриншот не загружен')

      payment.reload

      expect(payment.payment_status).to eq('transferring')
    end
  end

  context 'merchant check required false' do
    let(:merchant) { create(:merchant, check_required: false) }
    let(:advertisement) { create(:advertisement, :deposit, payment_system: 'Tinkoff') }
    let(:payment) { create(:payment, :deposit, :transferring, advertisement: advertisement, merchant: merchant) }

    scenario 'client try to completed deposit' do
      expect(page).not_to have_content('Добавьте изображение чека:')

      click_on 'Оплата завершена'

      expect(page).to have_content('Идёт обработка')
      expect(page).to have_content('Ожидайте пожалуйста...')
      expect(page).to have_content("uuid: #{payment.uuid}")

      payment.reload

      expect(payment.payment_status).to eq('confirming')
    end
  end
end