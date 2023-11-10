# frozen_string_literal: true

class Mask < ApplicationRecord
  validates_presence_of :sender, :regexp_type, :regexp

  def to_regexp
    Regexp.new([regexp[0], regexp[-1]].all?('/') ? regexp[1..-2] : regexp)
  end
end
