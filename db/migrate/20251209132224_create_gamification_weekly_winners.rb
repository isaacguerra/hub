class CreateGamificationWeeklyWinners < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_weekly_winners do |t|
      t.references :apoiador, null: false, foreign_key: true
      t.date :week_start_date
      t.date :week_end_date
      t.integer :points_total
      t.text :winning_strategy

      t.timestamps
    end
  end
end
