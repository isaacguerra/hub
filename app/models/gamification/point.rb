class Gamification::Point < ApplicationRecord
  include ProjectScoped
  acts_as_tenant :projeto
  belongs_to :projeto, optional: true
  belongs_to :apoiador

  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :apoiador_id, uniqueness: true
end
