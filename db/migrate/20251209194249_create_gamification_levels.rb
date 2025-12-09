class CreateGamificationLevels < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_levels do |t|
      t.integer :level
      t.integer :experience_threshold

      t.timestamps
    end
    add_index :gamification_levels, :level
  end
end
