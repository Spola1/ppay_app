# frozen_string_literal: true

class Mask < ApplicationRecord
  validates_presence_of :sender, :regexp_type, :regexp

  validates :thousands_separator, :decimal_separator, presence: true, if: :regexp_type_is_sum?

  def regexp_type_is_sum?
    regexp_type == 'Сумма'
  end

  def to_regexp
    Regexp.new([regexp[0], regexp[-1]].all?('/') ? regexp[1..-2] : regexp)
  end
end
