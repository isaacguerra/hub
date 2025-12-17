require "test_helper"

class EventoTest < ActiveSupport::TestCase
  test "deve notificar novo evento apos criar" do
    coordenador = apoiadores(:joao_candidato)
    evento = Evento.new(
      titulo: "Novo Evento Teste",
      data: 1.day.from_now,
      local: "Local Teste",
      descricao: "Descricao Teste",
      coordenador: coordenador,
      projeto_id: projetos(:default_project).id
    )

    mock = Minitest::Mock.new
    mock.expect :call, nil, [ evento ]

    Mensageria::Notificacoes::Eventos.stub :notificar_novo_evento, mock do
      assert evento.save
    end

    assert mock.verify
  end

  test "deve notificar atualizacao de evento apos update" do
    evento = eventos(:reuniao_geral)

    mock = Minitest::Mock.new
    mock.expect :call, nil, [ evento ]

    Mensageria::Notificacoes::Eventos.stub :notificar_atualizacao_evento, mock do
      evento.update(titulo: "Titulo Atualizado")
    end

    assert mock.verify
  end
end
