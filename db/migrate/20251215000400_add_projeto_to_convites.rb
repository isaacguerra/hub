class AddProjetoToConvites < ActiveRecord::Migration[8.1]
  def change
    add_reference :convites, :projeto, foreign_key: false, index: true, null: true
  end
end
