# frozen_string_literal: true

# spec/models/advertisement_spec.rb

require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  shared_examples 'algorithm' do
    before do
      # advertisement 1 - много активный платежей в процессе с такой же суммой
      create_list(:payment, 10, :transferring, advertisement: advertisement1)

      # advertisement 2 - много активных платежей с разными суммами, в том числе с такой же
      create_list(:payment, 6, :transferring, advertisement: advertisement2)
      create_list(:payment, 6, :transferring, advertisement: advertisement2, national_currency_amount: 200)

      # advertisement 3 - много неактивных завершенных платежей с такой же суммой, но мало активных
      create_list(:payment, 20, :completed, advertisement: advertisement3)
      create_list(:payment, 4, :transferring, advertisement: advertisement3)

      # advertisement 4 - мало активных платежей с такой же суммой,
      # должно иметь такой же приоритет как и advertisement_3, так как не должно зависеть от
      # завершенных платежей, поэтому между 3 и 4 должен быть рандомный результат
      create_list(:payment, 4, :transferring, advertisement: advertisement4)

      # advertisement 5 - мало активных платежей с такой же суммой
      # и мало платежей transferring с такой же суммой на арбитраже,
      # но много платежей confirming с такой же суммой на арбитраже

      create_list(:payment, 1, :transferring, advertisement: advertisement5)
      create_list(:payment, 1, :transferring, advertisement: advertisement5, arbitration: true)
      create_list(:payment, 10, :confirming, advertisement: advertisement5, arbitration: true)

      # advertisement 6 - без платежей вообще

      # avertisement 7 - с большим количеством активных платежей и с суммами в пределах 5% от суммы входящего платежа
      create_list(:payment, 3, :transferring, advertisement: advertisement7, national_currency_amount: 101)
      create_list(:payment, 3, :transferring, advertisement: advertisement7, national_currency_amount: 102)
      create_list(:payment, 3, :transferring, advertisement: advertisement7, national_currency_amount: 99)

      # advertisement 8 - с большим количеством активных платежей и с отличием более 5% от суммы входящего платежа
      create_list(:payment, 3, :transferring, advertisement: advertisement8, national_currency_amount: 400)
      create_list(:payment, 3, :transferring, advertisement: advertisement8, national_currency_amount: 250)
      create_list(:payment, 3, :transferring, advertisement: advertisement8, national_currency_amount: 10)

      # advertisement 9 - больше времени на подтверждение
      create_list(:payment, 8, :transferring, advertisement: advertisement9, status_changed_at: 5.minutes.ago)

      # advertisement 10 - меньше времени на подтверждение
      create_list(:payment, 8, :transferring, advertisement: advertisement10, status_changed_at: 7.minutes.ago)
    end

    it 'returns sorted list of advertisements' do
      is_expected.to(eq([advertisement6, advertisement8, advertisement5, advertisement4, advertisement3,
                         advertisement2, advertisement9, advertisement10, advertisement7, advertisement1])
                 .or(eq([advertisement6, advertisement8, advertisement5, advertisement3, advertisement4,
                         advertisement2, advertisement9, advertisement10, advertisement7, advertisement1])))
    end
  end

  describe '.algorithm deposit' do
    subject { Advertisement.for_deposit(payment) }

    let!(:advertisement1) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement6) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement7) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement8) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement9) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement10) { create(:advertisement, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :deposit, :processer_search) }

    it_behaves_like 'algorithm'
  end

  describe '.algorithm withdrawal' do
    subject { Advertisement.for_withdrawal(payment) }

    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement6) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement7) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement8) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement9) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement10) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    it_behaves_like 'algorithm'
  end

  # Тесты для каждоко скоупа отдельно

  describe '.order_by_transferring_and_confirming_payments' do
    subject { Advertisement.for_deposit(payment) }

    let(:payment) { create(:payment, :deposit, :processer_search) }

    let!(:advertisement1) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, payment_system: 'Sberbank') }

    before do
      # сортировка по активным платежам
      create_list(:payment, 2, payment_status: 'confirming', advertisement: advertisement1)
      create_list(:payment, 3, payment_status: 'transferring', advertisement: advertisement1)

      create_list(:payment, 3, payment_status: 'transferring', advertisement: advertisement2)
      create_list(:payment, 1, payment_status: 'confirming', advertisement: advertisement2)

      create_list(:payment, 2, payment_status: 'transferring', advertisement: advertisement3)
    end

    it 'orders advertisements by the count of transferring and confirming payments' do
      expect(subject).to eq([advertisement3, advertisement2, advertisement1])
    end
  end

  describe '.order_by_similar_payments' do
    subject { Advertisement.for_payment(payment).order_by_similar_payments(payment.national_currency_amount) }

    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement4) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement5) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    before do
      # сортировка по активным платежам(одинаковое количество платежей в каждом объявлении, но разное количество
      # 'похожих' платежей

      # 2 похожих платежа
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 40)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 151)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 102)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 102)
      create(:payment, :transferring, advertisement: advertisement1, national_currency_amount: 143)

      # 0 похожих платежей
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 190)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 25)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 135)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 15)
      create(:payment, :transferring, advertisement: advertisement2, national_currency_amount: 140)

      # 1 похожий платеж
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 101)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 117)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 190)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 220)
      create(:payment, :transferring, advertisement: advertisement3, national_currency_amount: 115)

      # добавляем объявление в котором просто больше платежей(и все они с одинаковой суммой)
      create_list(:payment, 6, :transferring, advertisement: advertisement4)

      # добавляем объявление в котором меньше платежей(и все они с одинаковой суммой)
      create_list(:payment, 2, :transferring, advertisement: advertisement5)
    end

    it 'orders advertisements by similar payments' do
      is_expected.to eq([advertisement2, advertisement3, advertisement1, advertisement5, advertisement4])
    end
  end

  describe '.order_by_remaining_confirmation_time' do
    subject { Advertisement.for_payment(payment).order_by_remaining_confirmation_time }

    let!(:advertisement1) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement2) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
    let!(:advertisement3) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }

    let(:payment) { create(:payment, :withdrawal, :processer_search) }

    before do
      # сортировка по оставшемуся времени
      create(:payment, :transferring, advertisement: advertisement1, status_changed_at: 1.day.ago)
      create(:payment, :transferring, advertisement: advertisement2, status_changed_at: 2.days.ago)
      create(:payment, :transferring, advertisement: advertisement3, status_changed_at: 3.days.ago)
    end

    it 'orders advertisements by remaining confirmation time' do
      is_expected.to eq([advertisement1, advertisement2, advertisement3])
    end
  end

  describe '.order_random' do
    subject(:results_for_processer1) do
      100.times
         .map { Advertisement.for_deposit(payment).order_random.first.reload.processer_id }
         .count { |id| id == processer1.id }
    end

    let(:payment) { create(:payment, :deposit, :processer_search) }

    let(:processer1) { create(:processer, sort_weight: 2) }
    let(:processer2) { create(:processer, sort_weight: 1) }

    let!(:advertisement1) { create(:advertisement, processer: processer1) }
    let!(:advertisement2) { create(:advertisement, processer: processer2) }

    it 'about 74 for processer1' do
      is_expected.to be_within(10).of(74)
    end

    context 'different count of advertisements' do
      let!(:advertisement1) { create(:advertisement, processer: processer1) }
      let!(:advertisement2) { create(:advertisement, processer: processer1) }
      let!(:advertisement3) { create(:advertisement, processer: processer2) }
      let!(:advertisement4) { create(:advertisement, processer: processer2) }
      let!(:advertisement5) { create(:advertisement, processer: processer2) }

      it 'about 84 for processer1' do
        is_expected.to be_within(10).of(84)
      end
    end
  end

  describe '.by_whitelisted_processers' do
    subject { Advertisement.by_whitelisted_processers(payment).order(id: :asc) }

    let(:payment) { create(:payment, merchant:) }

    let(:merchant) { create :merchant, only_whitelisted_processers: }

    let(:processer1) { create :processer }
    let(:processer2) { create :processer }
    let(:processer3) { create :processer }

    let!(:advertisement1) { create :advertisement, processer: processer1 }
    let!(:advertisement2) { create :advertisement, processer: processer2 }
    let!(:advertisement3) { create :advertisement, processer: processer3 }
    let!(:advertisement4) { create :advertisement, processer: processer2 }
    let!(:advertisement5) { create :advertisement, processer: processer1 }

    before do
      merchant.whitelisted_processers << processer1 << processer3
    end

    context 'merchant is set to select only whitelisted processers' do
      let(:only_whitelisted_processers) { true }

      it 'selects only whitelisted processers advertisements' do
        is_expected.to eq([advertisement1, advertisement3, advertisement5])
      end
    end

    context 'merchant is not set to select only whitelisted processers' do
      let(:only_whitelisted_processers) { false }

      it 'selects all advertisements' do
        is_expected.to eq([advertisement1, advertisement2, advertisement3, advertisement4, advertisement5])
      end
    end
  end

  describe '.by_payment_system' do
    subject { Advertisement.by_payment_system(payment.payment_system, payment.card_number, payment.type) }

    let!(:advertisement1) { create(:advertisement, payment_system: 'Tinkoff', sbp_phone_number: '') }
    let!(:advertisement2) { create(:advertisement, payment_system: 'AlfaBank', sbp_phone_number: '') }
    let!(:advertisement3) { create(:advertisement, payment_system: 'Tinkoff', sbp_phone_number: '+77777777777') }
    let!(:advertisement4) { create(:advertisement, payment_system: 'Sberbank', sbp_phone_number: '') }
    let!(:advertisement5) { create(:advertisement, payment_system: 'Tinkoff', sbp_phone_number: '+999999999999') }
    let!(:advertisement6) { create(:advertisement, payment_system: 'Sberbank', sbp_phone_number: '') }
    let!(:advertisement7) { create(:advertisement, payment_system: 'Tinkoff', sbp_phone_number: '') }
    let!(:advertisement8) { create(:advertisement, payment_system: 'AlfaBank', sbp_phone_number: '+88888888888') }
    let!(:advertisement9) { create(:advertisement, payment_system: 'AlfaBank', sbp_phone_number: '') }
    let!(:advertisement10) { create(:advertisement, payment_system: 'Sberbank', sbp_phone_number: '+111111111111') }
    let!(:advertisement11) { create(:advertisement, :withdrawal, payment_system: 'Sberbank', sbp_phone_number: '+111111111111') }

    context 'when payment system is SBP for deposit' do
      let!(:payment) { create(:payment, :deposit, :processer_search, :SBP) }

      it 'selects advertisements only with sbp phone number' do
        is_expected.to eq([advertisement3, advertisement5, advertisement8, advertisement10, advertisement11])
      end
    end
  
    context 'when payment system is not SBP for deposit' do
      let!(:payment) { create(:payment, :deposit, :processer_search) }
  
      it 'selects advertisements with payment.payment_system independently of sbp_phone_number' do
        is_expected.to eq([advertisement4, advertisement6, advertisement10, advertisement11])
      end
    end

    context 'when payment system is SBP for withdrawal' do
      let!(:payment) { create(:payment, :withdrawal, :processer_search, :SBP, card_number: '+111111111111') }

      it 'selects advertisements only with correct sbp phone number' do
        is_expected.to eq([advertisement3, advertisement5, advertisement8, advertisement10, advertisement11])
      end
    end

    context 'when payment system is not SBP for withdrawal' do
      let!(:payment) { create(:payment, :withdrawal, :processer_search) }
  
      it 'selects advertisements with payment.payment_system independently of sbp_phone_number' do
        is_expected.to eq([advertisement4, advertisement6, advertisement10, advertisement11])
      end
    end
  end
end
