class CreateComunicadoApoiadores < ActiveRecord::Migration[8.1]
  def change
    create_table :comunicado_apoiadores, id: false do |t|
      t.references :comunicado, null: false, foreign_key: true
      t.references :apoiador, null: false, foreign_key: true
      t.boolean :recebido, null: false, default: false
      t.boolean :engajado, null: false, default: false
      t.timestamps
    end
    
    add_index :comunicado_apoiadores, [:comunicado_id, :apoiador_id], unique: true
  end
end
