require "test_helper"

class LinkpainelTest < ActiveSupport::TestCase
  def setup
    ENV['BASE_URL'] = "http://localhost:3000"
    @linkpainel = Linkpainel.create!(
      apoiador: apoiadores(:pedro_lider),
      url: "http://example.com/dashboard"
    )
  end

  # Validações básicas
  test "deve ser válido com atributos válidos" do
    assert @linkpainel.valid?
  end

  test "deve gerar slug automaticamente" do
    assert_not_nil @linkpainel.slug
    assert @linkpainel.slug.length > 0
  end

  test "slug deve ser único" do
    slug = @linkpainel.slug
    outro_link = Linkpainel.new(
      apoiador: apoiadores(:ana_apoiadora),
      url: "http://example.com/other"
    )
    outro_link.save
    
    assert_not_equal slug, outro_link.slug
  end

  # Testes de associação
  test "deve pertencer a apoiador" do
    assert_respond_to @linkpainel, :apoiador
    assert_equal apoiadores(:pedro_lider), @linkpainel.apoiador
  end

  # Testes de url_completa
  test "url_completa deve retornar URL com slug" do
    url = @linkpainel.url_completa
    assert_includes url, @linkpainel.slug
    assert_includes url, "http"
  end

  # Testes de validade e expiração
  test "link deve estar ativo inicialmente" do
    assert_equal 'ativo', @linkpainel.status
  end

  test "valido? deve retornar true para link ativo não expirado" do
    assert @linkpainel.valido?
  end

  test "valido? deve retornar false após 2 minutos para link ativo" do
    # Simula link criado há 3 minutos
    @linkpainel.update_column(:created_at, 3.minutes.ago)
    assert_not @linkpainel.valido?
  end

  test "valido? deve retornar true para link usado dentro de 30 minutos" do
    @linkpainel.marcar_como_usado!("192.168.1.1")
    assert @linkpainel.valido?
  end

  test "valido? deve retornar false para link usado há mais de 30 minutos" do
    @linkpainel.marcar_como_usado!("192.168.1.1")
    @linkpainel.update_column(:updated_at, 31.minutes.ago)
    assert_not @linkpainel.valido?
  end

  # Testes de marcar_como_usado!
  test "marcar_como_usado! deve atualizar usado e ip" do
    ip = "192.168.1.100"
    @linkpainel.marcar_como_usado!(ip)
    
    assert_equal 'usado', @linkpainel.status
    assert_equal ip, @linkpainel.real_ip
    assert_not_equal 'ativo', @linkpainel.status
  end

  # Testes de validar_ip
  test "validar_ip deve retornar true para mesmo IP" do
    ip = "10.0.0.1"
    @linkpainel.marcar_como_usado!(ip)
    
    assert @linkpainel.validar_ip(ip)
  end

  test "validar_ip deve retornar false para IP diferente" do
    @linkpainel.marcar_como_usado!("10.0.0.1")
    
    assert_not @linkpainel.validar_ip("10.0.0.2")
  end

  test "validar_ip deve retornar true para link não usado" do
    # Se o link não foi usado, validar_ip retorna true (não há restrição de IP ainda)
    assert @linkpainel.validar_ip("192.168.1.1")
  end

  # Testes de expirar!
  test "expirar! deve marcar link como inativo" do
    @linkpainel.expirar!
    assert_equal 'expirado', @linkpainel.status
  end

  # Testes de scopes
  test "scope ativos deve retornar apenas links ativos" do
    link_ativo = Linkpainel.create!(apoiador: apoiadores(:maria_coord_geral), url: "http://example.com/1")
    link_expirado = Linkpainel.create!(apoiador: apoiadores(:joao_candidato), url: "http://example.com/2")
    link_expirado.expirar!
    
    ativos = Linkpainel.ativos
    assert_includes ativos, link_ativo
    assert_not_includes ativos, link_expirado
  end

  test "scope usados_validos deve retornar links usados e dentro da validade" do
    link_usado = Linkpainel.create!(apoiador: apoiadores(:maria_coord_geral), url: "http://example.com/1")
    link_usado.marcar_como_usado!("192.168.1.1")
    
    usados = Linkpainel.usados_validos
    assert_includes usados, link_usado
  end

  # Teste de fluxo completo
  test "fluxo completo: criar -> usar -> validar IP -> expirar" do
    # 1. Criar link
    link = Linkpainel.create!(apoiador: apoiadores(:pedro_lider), url: "http://example.com/flow")
    assert link.valido?
    assert_equal 'ativo', link.status
    
    # 2. Marcar como usado
    ip = "203.0.113.50"
    link.marcar_como_usado!(ip)
    assert link.valido?
    assert_not_equal 'ativo', link.status
    assert_equal ip, link.real_ip
    
    # 3. Validar IP correto
    assert link.validar_ip(ip)
    
    # 4. Validar IP incorreto
    assert_not link.validar_ip("203.0.113.51")
    
    # 5. Expirar manualmente
    link.expirar!
    assert_not link.valido?
  end
end
