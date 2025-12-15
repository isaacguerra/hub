class AddProjetoToGamificationChallengeParticipants < ActiveRecord::Migration[8.1]
  def change
    add_reference :gamification_challenge_participants, :projeto, foreign_key: false, index: true, null: true
  end
end
