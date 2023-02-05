# frozen_string_literal: true

class RsaEncryptionService
  attr_reader :data, :key

  def initialize(data, key)
    @data = data
    @key = OpenSSL::PKey::RSA.new(key)
  end

  def public_encrypt
    Base64.encode64(key.public_encrypt(data))
  end

  def public_decrypt
    key.public_decrypt(Base64.decode64(data))
  end

  def encrypt
    Base64.encode64(key.private_encrypt(data))
  end

  def decrypt
    key.private_decrypt(Base64.decode64(data))
  end
end
