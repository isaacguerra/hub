require "test_helper"

class Mensageria::Notificacoes::EventosTest < ActiveSupport::TestCase
  test "notificar_novo_evento deve chamar logger" do
    evento = eventos(:reuniao_geral)

    call_count = 0
    stub_logger = ->(**args) { call_count += 1 }

    Mensageria::Logger.stub :log_mensagem_apoiador, stub_logger do
      Mensageria::Notificacoes::Eventos.notificar_novo_evento(evento)
    end

    assert call_count > 0, "Deveria ter chamado o logger pelo menos uma vez"
  end

  test "notificar_atualizacao_evento deve chamar logger" do
    evento = eventos(:reuniao_geral)

    call_count = 0
    stub_logger = ->(**args) { call_count += 1 }

    Mensageria::Logger.stub :log_mensagem_apoiador, stub_logger do
      Mensageria::Notificacoes::Eventos.notificar_atualizacao_evento(evento)
    end

    assert call_count > 0, "Deveria ter chamado o logger pelo menos uma vez"
  end
end
