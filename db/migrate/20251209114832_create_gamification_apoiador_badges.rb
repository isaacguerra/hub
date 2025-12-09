class CreateGamificationApoiadorBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_apoiador_badges do |t|
      t.references :apoiador, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: { to_table: :gamification_badges }
      t.datetime :awarded_at

      t.timestamps
    end
    add_index :gamification_apoiador_badges, [:apoiador_id, :badge_id], unique: true
  end
end
