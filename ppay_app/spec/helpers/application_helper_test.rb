# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create :merchant, :with_all_kind_of_payments }

  describe 'hotlist_payments' do
    subject { helper.hotlist_payments(user) }

    it 'returns decorated deposits' do
      expect(subject.count).to eq 2
      expect([DepositDecorator, WithdrawalDecorator].include?(subject.first.class)).to be_truthy
    end
  end

  describe '#country_flag_icon' do
    it 'returns the correct flag icon for the given locale' do
      expect(helper.country_flag_icon(:en)).to eq('<span class="flag-icon flag-icon-gb"></span>')
      expect(helper.country_flag_icon(:id)).to eq('<span class="flag-icon flag-icon-id"></span>')
      expect(helper.country_flag_icon(:kk)).to eq('<span class="flag-icon flag-icon-kz"></span>')
      expect(helper.country_flag_icon(:ky)).to eq('<span class="flag-icon flag-icon-kg"></span>')
      expect(helper.country_flag_icon(:ru)).to eq('<span class="flag-icon flag-icon-ru"></span>')
      expect(helper.country_flag_icon(:tg)).to eq('<span class="flag-icon flag-icon-tj"></span>')
      expect(helper.country_flag_icon(:tr)).to eq('<span class="flag-icon flag-icon-tr"></span>')
      expect(helper.country_flag_icon(:uk)).to eq('<span class="flag-icon flag-icon-ua"></span>')
      expect(helper.country_flag_icon(:uz)).to eq('<span class="flag-icon flag-icon-uz"></span>')
    end
  end

  describe '#locale_to_country_code' do
    it 'returns the correct country code for the given locale' do
      expect(helper.send(:locale_to_country_code, :en)).to eq('gb')
      expect(helper.send(:locale_to_country_code, :id)).to eq('id')
      expect(helper.send(:locale_to_country_code, :kk)).to eq('kz')
      expect(helper.send(:locale_to_country_code, :ky)).to eq('kg')
      expect(helper.send(:locale_to_country_code, :ru)).to eq('ru')
      expect(helper.send(:locale_to_country_code, :tg)).to eq('tj')
      expect(helper.send(:locale_to_country_code, :tr)).to eq('tr')
      expect(helper.send(:locale_to_country_code, :uk)).to eq('ua')
      expect(helper.send(:locale_to_country_code, :uz)).to eq('uz')
    end

    it 'returns nil for unknown locale' do
      expect(helper.send(:locale_to_country_code, :fr)).to be_nil
    end
  end
end
