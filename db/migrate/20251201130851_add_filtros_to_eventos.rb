class AddFiltrosToEventos < ActiveRecord::Migration[8.1]
  def change
    add_reference :eventos, :filtro_funcao, null: true, foreign_key: { to_table: :funcoes }
    add_reference :eventos, :filtro_municipio, null: true, foreign_key: { to_table: :municipios }
    add_reference :eventos, :filtro_regiao, null: true, foreign_key: { to_table: :regioes }
    add_reference :eventos, :filtro_bairro, null: true, foreign_key: { to_table: :bairros }
  end
end
