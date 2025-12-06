require "test_helper"

class Mensageria::Notificacoes::EventosTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "notificar_novo_evento deve enfileirar job" do
    evento = eventos(:reuniao_geral)

    assert_enqueued_with(job: SendWhatsappJob) do
      Mensageria::Notificacoes::Eventos.notificar_novo_evento(evento)
    end
  end

  test "notificar_atualizacao_evento deve enfileirar job" do
    evento = eventos(:reuniao_geral)

    assert_enqueued_with(job: SendWhatsappJob) do
      Mensageria::Notificacoes::Eventos.notificar_atualizacao_evento(evento)
    end
  end
end
