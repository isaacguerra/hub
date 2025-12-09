class CreateGamificationActionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_action_logs do |t|
      t.references :apoiador, null: false, foreign_key: true
      t.string :action_type, null: false
      t.references :resource, polymorphic: true, null: true
      t.integer :points_awarded, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :gamification_action_logs, [:apoiador_id, :action_type]
  end
end
