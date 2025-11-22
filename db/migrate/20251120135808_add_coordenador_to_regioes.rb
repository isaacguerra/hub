class AddCoordenadorToRegioes < ActiveRecord::Migration[8.1]
  def change
    add_reference :regioes, :coordenador, foreign_key: { to_table: :apoiadores }
  end
end
