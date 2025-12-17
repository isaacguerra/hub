class AddIndexesToApoiadores < ActiveRecord::Migration[8.1]
  def change
    add_index :apoiadores, :lider_id unless index_exists?(:apoiadores, :lider_id)
    add_index :apoiadores, :municipio_id unless index_exists?(:apoiadores, :municipio_id)
    add_index :apoiadores, :regiao_id unless index_exists?(:apoiadores, :regiao_id)
    add_index :apoiadores, :bairro_id unless index_exists?(:apoiadores, :bairro_id)
  end
end
