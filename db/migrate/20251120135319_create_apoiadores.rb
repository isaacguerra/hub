class CreateApoiadores < ActiveRecord::Migration[8.1]
  def change
    create_table :apoiadores do |t|
      t.string :name, null: false
      t.string :whatsapp, null: false
      t.string :facebook
      t.string :instagram
      t.string :tiktok
      t.references :municipio, null: false, foreign_key: true
      t.references :regiao, null: false, foreign_key: true
      t.references :bairro, null: false, foreign_key: true
      t.references :funcao, null: false, foreign_key: true
      t.references :lider, foreign_key: { to_table: :apoiadores }
      t.string :secao_eleitoral
      t.string :titulo_eleitoral
      t.string :zona_eleitoral
      t.timestamps
    end
  end
end
