class CreateComunicados < ActiveRecord::Migration[8.1]
  def change
    create_table :comunicados do |t|
      t.string :titulo, null: false
      t.text :mensagem, null: false
      t.string :imagem
      t.string :link_whatsapp
      t.string :link_instagram
      t.string :link_facebook
      t.string :link_tiktok
      t.references :regiao, foreign_key: true
      t.references :lider, null: false, foreign_key: { to_table: :apoiadores }
      t.datetime :data, null: false
      t.timestamps
    end
  end
end
