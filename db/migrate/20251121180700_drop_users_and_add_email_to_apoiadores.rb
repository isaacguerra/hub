class DropUsersAndAddEmailToApoiadores < ActiveRecord::Migration[8.1]
  def change
    drop_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.references :apoiador, null: false, foreign_key: true
      t.timestamps
    end

    add_column :apoiadores, :email, :string
    add_index :apoiadores, :email, unique: true
  end
end
