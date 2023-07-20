class Mask < ApplicationRecord
  validates_presence_of :regexp_type, :regexp
end
