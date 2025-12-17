class AddProjetoToGamificationChallenges < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:gamification_challenges, :projeto_id)
      add_reference :gamification_challenges, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
