class CreateProjetosV2 < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:projetos)
      create_table :projetos do |t|
      t.string :name, null: false
      t.string :candidato
      t.string :candidato_whatsapp
      t.text :descricao
      t.string :site
      t.string :slug
      t.jsonb :settings, default: {}
      t.boolean :active, default: true, null: false

      t.timestamps
    end
      add_index :projetos, :slug, unique: true
    end
  end
end
