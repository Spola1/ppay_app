class Mask < ApplicationRecord
  validates_presence_of :app, :request_type
end
