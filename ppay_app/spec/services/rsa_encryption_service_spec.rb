# frozen_string_literal: true

require 'rails_helper'

shared_context 'public_encrypt' do
  xdescribe '#public_encrypt' do
    subject { described_class.new(data, Settings.rsa.public_key).public_encrypt }

    let(:decrypted_subject) { described_class.new(subject, Settings.rsa.private_key).decrypt }

    it 'returns decryptable data' do
      expect(decrypted_subject).to eq(data)
    end
  end
end

shared_context 'public_decrypt' do
  xdescribe '#public_decrypt' do
    subject { described_class.new(encrypted_data, Settings.rsa.public_key).public_decrypt }

    let(:encrypted_data) { described_class.new(data, Settings.rsa.private_key).encrypt }

    it 'returns string "test rsa"' do
      is_expected.to eq(data)
    end
  end
end

shared_context 'encrypt' do
  xdescribe '#encrypt' do
    subject { described_class.new(data, Settings.rsa.private_key).encrypt }

    let(:decrypted_subject) { described_class.new(subject, Settings.rsa.public_key).public_decrypt }

    it 'returns decryptable data' do
      expect(decrypted_subject).to eq(data)
    end
  end
end

shared_context 'decrypt' do
  xdescribe '#decrypt' do
    subject { described_class.new(encrypted_data, Settings.rsa.private_key).decrypt }

    let(:encrypted_data) { described_class.new(data, Settings.rsa.public_key).public_encrypt }

    it 'returns string "test rsa"' do
      is_expected.to eq(data)
    end
  end
end

RSpec.describe RsaEncryptionService, type: :service do
  let(:data) { 'test rsa' }

  include_context 'public_encrypt'

  include_context 'public_decrypt'

  include_context 'encrypt'

  include_context 'decrypt'
end
