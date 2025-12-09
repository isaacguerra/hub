class AddRewardToGamificationChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :gamification_challenges, :reward, :string
  end
end
