class Gamification::Point < ApplicationRecord
  include ProjectScoped

  belongs_to :projeto, optional: true
  belongs_to :apoiador

  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :apoiador_id, uniqueness: true
end
