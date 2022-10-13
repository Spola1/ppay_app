class Processer < User
  has_many :advertisements, foreign_key: :processer_id

  belongs_to :working_group, optional: true
end

