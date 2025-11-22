class CreateVisitas < ActiveRecord::Migration[8.1]
  def change
    create_table :visitas do |t|
      t.references :lider, null: false, foreign_key: { to_table: :apoiadores }
      t.references :apoiador, null: false, foreign_key: true
      t.text :relato, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
