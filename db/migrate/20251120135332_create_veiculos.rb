class CreateVeiculos < ActiveRecord::Migration[8.1]
  def change
    create_table :veiculos do |t|
      t.string :modelo, null: false
      t.string :placa, null: false
      t.string :tipo, null: false
      t.boolean :disponivel, null: false, default: true
      t.references :apoiador, null: false, foreign_key: true
      t.timestamps
    end
  end
end
