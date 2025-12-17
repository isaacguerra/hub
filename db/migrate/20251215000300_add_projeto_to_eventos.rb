class AddProjetoToEventos < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:eventos, :projeto_id)
      add_reference :eventos, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
