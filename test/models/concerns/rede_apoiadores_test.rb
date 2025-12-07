require "test_helper"

class RedeApoiadoresTest < ActiveSupport::TestCase
  def setup
    # Setup clean data to avoid fixture confusion
    @municipio = Municipio.create!(name: "Teste Mun")
    @regiao = Regiao.create!(name: "Teste Reg", municipio: @municipio)
    @bairro = Bairro.create!(name: "Teste Bairro", regiao: @regiao)

    @f_candidato = Funcao.find_by(name: "Candidato")
    @f_geral = Funcao.find_by(name: "Coordenador Geral")
    @f_municipal = Funcao.find_by(name: "Coordenador de Município")
    @f_regional = Funcao.find_by(name: "Coordenador de Região")
    @f_bairro = Funcao.find_by(name: "Coordenador de Bairro")
    @f_lider = Funcao.find_by(name: "Líder")
    @f_apoiador = Funcao.find_by(name: "Apoiador")

    @candidato = Apoiador.create!(name: "Candidato", whatsapp: "5511999990001", funcao: @f_candidato, municipio: @municipio, regiao: @regiao, bairro: @bairro)
    @geral = Apoiador.create!(name: "Geral", whatsapp: "5511999990002", funcao: @f_geral, municipio: @municipio, regiao: @regiao, bairro: @bairro)
    @municipal = Apoiador.create!(name: "Municipal", whatsapp: "5511999990003", funcao: @f_municipal, municipio: @municipio, regiao: @regiao, bairro: @bairro)
    @regional = Apoiador.create!(name: "Regional", whatsapp: "5511999990004", funcao: @f_regional, municipio: @municipio, regiao: @regiao, bairro: @bairro)
    @coord_bairro = Apoiador.create!(name: "Coord Bairro", whatsapp: "5511999990005", funcao: @f_bairro, municipio: @municipio, regiao: @regiao, bairro: @bairro)

    @lider = Apoiador.create!(name: "Lider", whatsapp: "5511999990006", funcao: @f_lider, municipio: @municipio, regiao: @regiao, bairro: @bairro, lider: @coord_bairro)
    @apoiador = Apoiador.create!(name: "Apoiador", whatsapp: "5511999990007", funcao: @f_apoiador, municipio: @municipio, regiao: @regiao, bairro: @bairro, lider: @lider)
  end

  test "coordenadores retorna toda a hierarquia acima" do
    coordenadores = @apoiador.coordenadores

    assert_includes coordenadores, @candidato
    assert_includes coordenadores, @geral
    assert_includes coordenadores, @municipal
    assert_includes coordenadores, @regional
    assert_includes coordenadores, @coord_bairro
  end

  test "liderados para coordenador municipal retorna todos do municipio" do
    liderados = @municipal.liderados

    # Deve incluir todos criados no setup pois são do mesmo município
    assert_includes liderados, @regional
    assert_includes liderados, @coord_bairro
    assert_includes liderados, @lider
    assert_includes liderados, @apoiador

    # Não deve incluir a si mesmo
    assert_not_includes liderados, @municipal
  end

  test "liderados para lider retorna subordinados recursivos" do
    liderados = @lider.liderados

    assert_includes liderados, @apoiador
    assert_not_includes liderados, @lider
    assert_not_includes liderados, @coord_bairro # Acima dele
  end

  test "rede_completa retorna estrutura correta" do
    rede = @apoiador.rede_completa

    assert_kind_of Array, rede[:coordenadores]
    assert_equal @lider, rede[:lider]
    # Pode ser Array ou Relation
    assert_respond_to rede[:liderados], :each
  end
end
