class CreateGamificationChallengeParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_challenge_participants do |t|
      t.references :challenge, null: false, foreign_key: { to_table: :gamification_challenges }
      t.references :apoiador, null: false, foreign_key: true
      t.jsonb :progress, default: {}
      t.integer :points, default: 0

      t.timestamps
    end
    add_index :gamification_challenge_participants, [:challenge_id, :apoiador_id], unique: true
  end
end
