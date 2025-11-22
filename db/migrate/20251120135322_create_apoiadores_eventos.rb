class CreateApoiadoresEventos < ActiveRecord::Migration[8.1]
  def change
    create_table :apoiadores_eventos, id: false do |t|
      t.references :apoiador, null: false, foreign_key: true
      t.references :evento, null: false, foreign_key: true
      t.datetime :assigned_at, null: false
      t.string :assigned_by, null: false
    end
    
    add_index :apoiadores_eventos, [:apoiador_id, :evento_id], unique: true
  end
end
