class RemoveRegiaoIdFromComunicados < ActiveRecord::Migration[8.1]
  def change
    remove_column :comunicados, :regiao_id, :bigint
  end
end
