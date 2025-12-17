class AddProjetoToComunicados < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:comunicados, :projeto_id)
      add_reference :comunicados, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
