class AddProjetoToApoiadoresEvento < ActiveRecord::Migration[8.1]
  def change
    add_reference :apoiadores_eventos, :projeto, foreign_key: false, index: true, null: true
  end
end
