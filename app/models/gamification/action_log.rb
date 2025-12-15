class Gamification::ActionLog < ApplicationRecord
  include ProjectScoped

  belongs_to :projeto, optional: true
  belongs_to :apoiador
  belongs_to :resource, polymorphic: true, optional: true

  validates :action_type, presence: true
  validates :points_awarded, presence: true
end
