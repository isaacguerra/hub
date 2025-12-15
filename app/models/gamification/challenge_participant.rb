class Gamification::ChallengeParticipant < ApplicationRecord
  include ProjectScoped

  belongs_to :projeto, optional: true
  belongs_to :challenge, class_name: "Gamification::Challenge"
  belongs_to :apoiador

  validates :challenge_id, uniqueness: { scope: :apoiador_id }
end
