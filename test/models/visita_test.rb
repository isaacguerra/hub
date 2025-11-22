require "test_helper"

class VisitaTest < ActiveSupport::TestCase
  def setup
    @visita = visitas(:visita_pendente)
    @lider = apoiadores(:pedro_lider)
    @apoiador = apoiadores(:ana_apoiadora)
  end

  # Validações básicas
  test "deve ser válido com atributos válidos" do
    assert @visita.valid?
  end

  test "não deve ser válido sem relato" do
    @visita.relato = nil
    assert_not @visita.valid?
    assert_includes @visita.errors[:relato], "can't be blank"
  end

  test "não deve ser válido sem status" do
    @visita.status = nil
    assert_not @visita.valid?
    assert_includes @visita.errors[:status], "can't be blank"
  end

  # Validação de status
  test "status deve ser pendente, concluida ou cancelada" do
    @visita.status = "pendente"
    assert @visita.valid?

    @visita.status = "concluida"
    assert @visita.valid?

    @visita.status = "cancelada"
    assert @visita.valid?

    @visita.status = "invalido"
    assert_not @visita.valid?
    assert_includes @visita.errors[:status], "is not included in the list"
  end

  # Testes de associações
  test "deve pertencer a lider" do
    assert_respond_to @visita, :lider
    assert_equal @lider, @visita.lider
  end

  test "deve pertencer a apoiador" do
    assert_respond_to @visita, :apoiador
    assert_equal @apoiador, @visita.apoiador
  end

  # Testes de callbacks
  test "deve notificar ao criar nova visita" do
    Mensageria::Notificacoes::Visitas.stub :notificar_nova_visita, true do
      nova_visita = Visita.create!(
        lider: @lider,
        apoiador: @apoiador,
        relato: "Nova visita agendada",
        status: "pendente"
      )
      assert nova_visita.persisted?
    end
  end

  test "deve notificar ao concluir visita" do
    Mensageria::Notificacoes::Visitas.stub :notificar_visita_realizada, true do
      @visita.update!(
        status: "concluida",
        relato: "Visita realizada com sucesso. Apoiador muito engajado."
      )
      assert_equal "concluida", @visita.status
    end
  end

  test "deve notificar ao cancelar visita" do
    @visita.update!(status: "cancelada", relato: "Visita cancelada por motivo X")
    assert_equal "cancelada", @visita.status
  end

  # Testes de fluxo completo
  test "fluxo completo: criar -> concluir visita" do
    Mensageria::Notificacoes::Visitas.stub :notificar_nova_visita, true do
      Mensageria::Notificacoes::Visitas.stub :notificar_visita_realizada, true do
        # 1. Criar visita
        visita = Visita.create!(
          lider: @lider,
          apoiador: @apoiador,
          relato: "Visita inicial",
          status: "pendente"
        )

        # 2. Concluir visita
        visita.update!(
          status: "concluida",
          relato: "Visita concluída. Apoiador comprometido com a causa."
        )

        assert_equal "concluida", visita.status
        assert visita.relato.include?("concluída")
      end
    end
  end
end
