class AddProjetoToComunicadoApoiador < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:comunicado_apoiadores, :projeto_id)
      add_reference :comunicado_apoiadores, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
