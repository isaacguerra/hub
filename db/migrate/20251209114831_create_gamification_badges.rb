class CreateGamificationBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_badges do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.jsonb :criteria, default: {}
      t.string :image_url

      t.timestamps
    end
    add_index :gamification_badges, :key, unique: true
  end
end
