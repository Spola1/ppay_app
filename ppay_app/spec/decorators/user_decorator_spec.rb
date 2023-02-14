# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDecorator do
  let(:user) {create :user, :merchant}
  describe '#human_type' do
    it 'should return Мерчант if type Merchant' do
      expect(user.decorate.human_type).to eq 'Мерчант'
    end
  end

  describe '#display_name' do
    it 'should return ID if nickname = nil and full_name = nil' do
      user.name = nil
      expect(user.decorate.display_name).to eq "ID: #{user.id}"
    end

    it 'should return full_name if nickname not presence' do
      expect(user.decorate.display_name).to eq user.decorate.full_name
    end

    it 'should return nickname if presence' do
      user.nickname = 'Artur'
      expect(user.decorate.display_name).to eq user.nickname
    end
  end

  describe '#full_name' do
    it 'should return nickname if type precense' do
      expect(user.decorate.full_name).to eq user.decorate.full_name
    end

    it 'should return false if type not precense' do
      user.nickname = nil
      expect(user.decorate.full_name).to eq false
    end
  end

  describe '#display_id' do
    it 'should return ID' do
      expect(user.decorate.display_id).to eq "ID: #{user.id}"
    end
  end
end
