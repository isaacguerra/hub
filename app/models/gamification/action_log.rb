class Gamification::ActionLog < ApplicationRecord
  acts_as_tenant :projeto
  belongs_to :apoiador
  belongs_to :resource, polymorphic: true, optional: true

  validates :action_type, presence: true
  validates :points_awarded, presence: true
end
