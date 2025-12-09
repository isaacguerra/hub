class CreateGamificationActionWeights < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_action_weights do |t|
      t.string :action_type
      t.integer :points
      t.string :description

      t.timestamps
    end
    add_index :gamification_action_weights, :action_type
  end
end
