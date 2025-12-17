class AddProjetoToGamificationPoints < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:gamification_points, :projeto_id)
      add_reference :gamification_points, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
