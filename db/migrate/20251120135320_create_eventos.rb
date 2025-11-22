class CreateEventos < ActiveRecord::Migration[8.1]
  def change
    create_table :eventos do |t|
      t.string :titulo, null: false
      t.text :descricao
      t.string :imagem
      t.string :link_whatsapp
      t.string :link_instagram
      t.string :link_facebook
      t.string :link_tiktok
      t.references :coordenador, null: false, foreign_key: { to_table: :apoiadores }
      t.datetime :data, null: false
      t.timestamps
    end
  end
end
