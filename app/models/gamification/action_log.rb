class Gamification::ActionLog < ApplicationRecord
  belongs_to :apoiador
  belongs_to :resource, polymorphic: true, optional: true

  validates :action_type, presence: true
  validates :points_awarded, presence: true
end
