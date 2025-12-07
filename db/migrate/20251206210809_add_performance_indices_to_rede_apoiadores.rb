class AddPerformanceIndicesToRedeApoiadores < ActiveRecord::Migration[8.1]
  def change
    # Otimiza a busca de funções por nome (usado em todos os joins)
    add_index :funcoes, :name, unique: true

    # Otimiza a busca de coordenadores específicos (Local + Função)
    # Ex: Buscar todos os "Coordenadores de Município" do "Município X"
    # Esses índices compostos evitam que o banco tenha que cruzar dois índices separados
    add_index :apoiadores, [ :municipio_id, :funcao_id ]
    add_index :apoiadores, [ :regiao_id, :funcao_id ]
    add_index :apoiadores, [ :bairro_id, :funcao_id ]
  end
end
