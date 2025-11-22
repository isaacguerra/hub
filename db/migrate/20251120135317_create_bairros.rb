class CreateBairros < ActiveRecord::Migration[8.1]
  def change
    create_table :bairros do |t|
      t.string :name, null: false
      t.references :regiao, null: false, foreign_key: true
      t.timestamps
    end
  end
end
