class AddProjetoToGamificationWeeklyWinners < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:gamification_weekly_winners, :projeto_id)
      add_reference :gamification_weekly_winners, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
