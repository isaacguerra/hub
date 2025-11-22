class CreateLinkpaineis < ActiveRecord::Migration[8.1]
  def change
    create_table :linkpaineis do |t|
      t.string :slug, null: false
      t.string :url, null: false
      t.references :apoiador, null: false, foreign_key: true
      t.string :status, null: false
      t.string :real_ip
      t.timestamps
    end
    
    add_index :linkpaineis, :slug, unique: true
  end
end
