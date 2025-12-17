class Gamification::ChallengeParticipant < ApplicationRecord
  acts_as_tenant :projeto
  belongs_to :challenge, class_name: "Gamification::Challenge"
  belongs_to :apoiador

  validates :challenge_id, uniqueness: { scope: :apoiador_id }
end
