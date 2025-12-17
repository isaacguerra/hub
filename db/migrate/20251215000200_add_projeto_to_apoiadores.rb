class AddProjetoToApoiadores < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:apoiadores, :projeto_id)
      add_reference :apoiadores, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
