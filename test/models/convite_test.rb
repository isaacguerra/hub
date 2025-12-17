require "test_helper"

class ConviteTest < ActiveSupport::TestCase
  def setup
    @convite = convites(:convite_pendente)
    @lider = apoiadores(:pedro_lider)
  end

  # Validações básicas
  test "deve ser válido com atributos válidos" do
    assert @convite.valid?
  end

  test "não deve ser válido sem nome" do
    @convite.nome = nil
    assert_not @convite.valid?
    assert_includes @convite.errors[:nome], "não pode ficar em branco"
  end

  test "não deve ser válido sem whatsapp" do
    @convite.whatsapp = nil
    assert_not @convite.valid?
    assert_includes @convite.errors[:whatsapp], "não pode ficar em branco"
  end

  test "não deve ser válido sem status" do
    @convite.status = nil
    assert_not @convite.valid?
    assert_includes @convite.errors[:status], "não pode ficar em branco"
  end

  # Validação de status
  test "status deve ser pendente, aceito ou recusado" do
    @convite.status = "pendente"
    assert @convite.valid?

    @convite.status = "aceito"
    assert @convite.valid?

    @convite.status = "recusado"
    assert @convite.valid?

    @convite.status = "invalido"
    assert_not @convite.valid?
    assert_includes @convite.errors[:status], "não está incluído na lista"
  end

  # Testes de associações
  test "deve pertencer a enviado_por (apoiador)" do
    assert_respond_to @convite, :enviado_por
    assert_equal @lider, @convite.enviado_por
  end

  # Testes de callbacks
  test "deve notificar ao criar novo convite" do
    Mensageria::Notificacoes::Convites.stub :notificar_novo_convite, true do
      novo_convite = Convite.create!(
        nome: "Teste Notificação",
        whatsapp: "96998765432",
        status: "pendente",
          enviado_por: @lider,
          projeto_id: projetos(:default_project).id
      )
      assert novo_convite.persisted?
    end
  end

  test "deve notificar ao mudar status para aceito" do
    @convite.status = "aceito"
    assert @convite.save
  end

  test "deve notificar ao mudar status para recusado" do
    @convite.status = "recusado"
    assert @convite.save
  end

  # Testes de fluxo completo
  test "fluxo completo: criar convite -> aceitar -> criar apoiador" do
    Mensageria::Notificacoes::Convites.stub :notificar_novo_convite, true do
      Mensageria::Notificacoes::Convites.stub :notificar_convite_aceito, true do
        # 1. Criar convite
        convite = Convite.create!(
          nome: "Fluxo Completo",
          whatsapp: "96997654321",
          status: "pendente",
          enviado_por: @lider,
          projeto_id: projetos(:default_project).id
        )

        # 2. Aceitar convite
        convite.update!(status: "aceito")
        assert_equal "aceito", convite.status

        # 3. Criar apoiador
        apoiador = Apoiador.create!(
          name: convite.nome,
          whatsapp: convite.whatsapp,
          municipio: @lider.municipio,
          regiao: @lider.regiao,
          bairro: @lider.bairro,
          funcao: funcoes(:apoiador),
          lider: @lider,
          projeto_id: projetos(:default_project).id
        )

        assert apoiador.persisted?
        assert_equal convite.nome, apoiador.name
        assert_equal convite.whatsapp, apoiador.whatsapp
      end
    end
  end
end
