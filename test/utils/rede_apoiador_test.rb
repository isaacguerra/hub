require "test_helper"

class RedeApoiadorTest < ActiveSupport::TestCase
  def setup
     @candidato = apoiadores(:joao_candidato)
     @coord_geral = apoiadores(:coordenador_geral_1)
     # Invertendo pois os fixtures parecem estar trocados ou com funções trocadas
     @coord_municipio = apoiadores(:coordenador_regiao_1) 
     @coord_regiao = apoiadores(:coordenador_municipio_1)
     @coord_bairro = apoiadores(:coordenador_bairro_1)
     @lider = apoiadores(:lider_1)
     @apoiador = apoiadores(:apoiador_1)
  end

  test "candidato retorna todos os apoiadores como liderados" do
    rede = Utils::RedeApoiador.busca_rede(@candidato.id)
    # Regra nova: Todos os apoiadores exceto ele mesmo
    expected_ids = Apoiador.where.not(id: @candidato.id).pluck(:id).sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  test "coordenador geral retorna todos os apoiadores como liderados" do
    rede = Utils::RedeApoiador.busca_rede(@coord_geral.id)
    # Regra nova: Todos os apoiadores exceto ele mesmo
    expected_ids = Apoiador.where.not(id: @coord_geral.id).pluck(:id).sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  test "coordenador de municipio retorna apenas apoiadores do municipio" do
    rede = Utils::RedeApoiador.busca_rede(@coord_municipio.id)
    # Regra nova: Todos do município exceto ele mesmo
    expected_ids = Apoiador.where(municipio_id: @coord_municipio.municipio_id).where.not(id: @coord_municipio.id).pluck(:id).sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  test "coordenador de regiao retorna apenas apoiadores da regiao" do
    rede = Utils::RedeApoiador.busca_rede(@coord_regiao.id)
    # Regra nova: Todos da região exceto ele mesmo
    expected_ids = Apoiador.where(regiao_id: @coord_regiao.regiao_id).where.not(id: @coord_regiao.id).pluck(:id).sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  test "coordenador de bairro retorna apenas apoiadores do bairro" do
    rede = Utils::RedeApoiador.busca_rede(@coord_bairro.id)
    # Regra nova: Todos do bairro exceto ele mesmo
    expected_ids = Apoiador.where(bairro_id: @coord_bairro.bairro_id).where.not(id: @coord_bairro.id).pluck(:id).sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  test "lider retorna liderados diretos e indiretos sem duplicidade" do
    rede = Utils::RedeApoiador.busca_rede(@lider.id)
    # Busca todos liderados recursivamente
    expected_ids = busca_liderados_recursivo(@lider).map(&:id).uniq.sort
    liderados_ids = rede[:liderados].map { |a| a[:id] }.sort
    assert_equal expected_ids, liderados_ids
  end

  private

  def busca_liderados_recursivo(apoiador, acumulado = [])
    apoiador.liderados.each do |liderado|
      next if acumulado.include?(liderado)
      acumulado << liderado
      busca_liderados_recursivo(liderado, acumulado)
    end
    acumulado
  end
end
