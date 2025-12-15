class AddProjetoToGamificationPoints < ActiveRecord::Migration[8.1]
  def change
    add_reference :gamification_points, :projeto, foreign_key: false, index: true, null: true
  end
end
