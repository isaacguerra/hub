class CreateConvites < ActiveRecord::Migration[8.1]
  def change
    create_table :convites do |t|
      t.string :nome, null: false
      t.string :whatsapp, null: false
      t.references :enviado_por, null: false, foreign_key: { to_table: :apoiadores }
      t.string :status, null: false
      t.timestamps
    end
  end
end
