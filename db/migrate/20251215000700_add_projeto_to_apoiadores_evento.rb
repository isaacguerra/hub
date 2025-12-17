class AddProjetoToApoiadoresEvento < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:apoiadores_eventos, :projeto_id)
      add_reference :apoiadores_eventos, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
