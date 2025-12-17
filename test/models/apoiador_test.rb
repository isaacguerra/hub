require "test_helper"

class ApoiadorTest < ActiveSupport::TestCase
  def setup
    @candidato = apoiadores(:joao_candidato)
    @coord_geral = apoiadores(:maria_coord_geral)
    @lider = apoiadores(:pedro_lider)
    @apoiador = apoiadores(:ana_apoiadora)
  end

  # Validações básicas
  test "deve ser válido com atributos válidos" do
    assert @apoiador.valid?
  end

  test "não deve ser válido sem name" do
    @apoiador.name = nil
    assert_not @apoiador.valid?
    assert_includes @apoiador.errors[:name], "não pode ficar em branco"
  end

  test "não deve ser válido sem whatsapp" do
    @apoiador.whatsapp = nil
    assert_not @apoiador.valid?
    assert_includes @apoiador.errors[:whatsapp], "não pode ficar em branco"
  end

  # Testes de hierarquia de liderança
  test "hierarquia_lideranca deve retornar array de líderes" do
    hierarquia = @apoiador.hierarquia_lideranca
    assert_instance_of Array, hierarquia
    assert hierarquia.any?
  end

  test "lideres deve ser alias de hierarquia_lideranca" do
    assert_equal @apoiador.hierarquia_lideranca, @apoiador.lideres
  end

  # Testes de subordinados
  test "todos_subordinados deve retornar subordinados diretos" do
    subordinados = @lider.todos_subordinados(incluir_indiretos: false)
    assert_includes subordinados, @apoiador
  end

  test "todos_subordinados deve incluir indiretos quando solicitado" do
    # Criar estrutura: lider -> apoiador1 -> apoiador2
    subordinados = @lider.todos_subordinados(incluir_indiretos: true)
    assert_instance_of Array, subordinados
  end

  test "total_subordinados_diretos deve contar corretamente" do
    count = @lider.total_subordinados_diretos
    assert_equal @lider.subordinados.count, count
  end

  # Testes de verificadores de função
  test "candidato? deve retornar true para candidato" do
    assert @candidato.candidato?
    assert_not @lider.candidato?
  end

  test "coordenador_geral? deve retornar true para coordenador geral" do
    assert @coord_geral.coordenador_geral?
    assert_not @lider.coordenador_geral?
  end

  test "lider? deve retornar true para líder" do
    assert @lider.lider?
    assert_not @apoiador.lider?
  end

  test "apoiador_base? deve retornar true para apoiador" do
    assert @apoiador.apoiador_base?
    assert_not @lider.apoiador_base?
  end

  test "pode_coordenar? deve retornar true para coordenadores e candidato" do
    assert @candidato.pode_coordenar?
    assert @coord_geral.pode_coordenar?
    assert_not @lider.pode_coordenar?
    assert_not @apoiador.pode_coordenar?
  end

  # Testes de callbacks
  test "deve notificar ao criar novo apoiador" do
    # Mock da mensageria para evitar chamadas reais
    Mensageria::Lideranca.stub :notificar, true do
      novo_apoiador = Apoiador.create!(
        name: "Teste Novo",
        whatsapp: "96999999999",
        municipio: @apoiador.municipio,
        regiao: @apoiador.regiao,
        bairro: @apoiador.bairro,
        funcao: funcoes(:apoiador),
        lider: @lider,
        projeto_id: projetos(:default_project).id
      )
      assert novo_apoiador.persisted?
    end
  end

  # Testes de promoção automática
  test "verificar_promocao_lider deve promover a líder com 25 subordinados" do
    # Criar 25 subordinados
    25.times do |i|
      Apoiador.create!(
        name: "Subordinado #{i}",
        whatsapp: "9699#{1000000 + i}",
        municipio: @apoiador.municipio,
        regiao: @apoiador.regiao,
        bairro: @apoiador.bairro,
        funcao: funcoes(:apoiador),
        lider: @apoiador,
        projeto_id: projetos(:default_project).id
      )
    end

    @apoiador.reload
    # Força verificação
    @apoiador.send(:verificar_promocao_lider)
    @apoiador.reload
    
    # Deve ter sido promovido a líder
    assert_equal funcoes(:lider).id, @apoiador.funcao_id
  end

  # Testes de associações
  test "deve ter associação com município" do
    assert_respond_to @apoiador, :municipio
    assert_equal "Macapá", @apoiador.municipio.name
  end

  test "deve ter associação com região" do
    assert_respond_to @apoiador, :regiao
    assert_equal "Centro", @apoiador.regiao.name
  end

  test "deve ter associação com bairro" do
    assert_respond_to @apoiador, :bairro
    assert_not_nil @apoiador.bairro
  end

  test "deve ter associação com função" do
    assert_respond_to @apoiador, :funcao
    assert_equal "Apoiador", @apoiador.funcao.name
  end

  test "deve ter associação com líder" do
    assert_respond_to @apoiador, :lider
    assert_equal @lider, @apoiador.lider
  end

  test "deve ter associação com subordinados" do
    assert_respond_to @lider, :subordinados
    assert_includes @lider.subordinados, @apoiador
  end
end
