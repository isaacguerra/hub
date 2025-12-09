class CreateGamificationChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_challenges do |t|
      t.string :title
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.jsonb :rules

      t.timestamps
    end
  end
end
