class CreateGamificationPoints < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_points do |t|
      t.references :apoiador, null: false, foreign_key: true, index: { unique: true }
      t.integer :points, default: 0, null: false
      t.integer :level, default: 1, null: false

      t.timestamps
    end
  end
end
