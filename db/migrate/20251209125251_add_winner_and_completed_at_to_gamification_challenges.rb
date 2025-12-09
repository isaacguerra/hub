class AddWinnerAndCompletedAtToGamificationChallenges < ActiveRecord::Migration[8.1]
  def change
    add_reference :gamification_challenges, :winner, null: true, foreign_key: { to_table: :apoiadores }
    add_column :gamification_challenges, :completed_at, :datetime
  end
end
