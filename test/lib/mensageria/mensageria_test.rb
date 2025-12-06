require "test_helper"
require "minitest/mock"
require "ostruct"

class MensageriaTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @apoiador = apoiadores(:lider_1)
    @convite = convites(:convite_pendente)
    @visita = visitas(:visita_pendente)
    @evento = OpenStruct.new(
      id: 1,
      titulo: "Reunião Geral",
      descricao: "Discussão de pautas",
      data: Time.now + 1.day,
      coordenador: @apoiador,
      descricao_publico_alvo: "Todos (Rede completa)",
      destinatarios_filtrados: Apoiador.where(id: @apoiador.id)
    )
    @comunicado = OpenStruct.new(
      id: 1,
      titulo: "Aviso Importante",
      mensagem: "Conteúdo do aviso",
      data: Time.now,
      lider: @apoiador,
      regiao: nil,
      apoiadores: Apoiador.where(id: [@apoiador.id])
    )
  end

  # Teste para Utils::BuscaImagemWhatsapp
  test "Utils::BuscaImagemWhatsapp deve fazer requisição POST correta" do
    ENV['N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP'] = "https://n8n.exemplo.com/webhook/busca-imagem"
    
    url = ENV['N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP']
    uri = URI(url)
    
    mock_http = Minitest::Mock.new
    mock_response = Minitest::Mock.new
    
    mock_response.expect :body, { "imageUrl" => "http://imagem.com/foto.jpg" }.to_json
    mock_http.expect :use_ssl=, true, [true]
    
    mock_http.expect :request, mock_response do |request|
      request.is_a?(Net::HTTP::Post) && 
      request.path == uri.path &&
      JSON.parse(request.body)["whatsappNumber"] == "96991234567"
    end

    Net::HTTP.stub :new, mock_http do
      resultado = Utils::BuscaImagemWhatsapp.buscar("96991234567")
      assert_equal "http://imagem.com/foto.jpg", resultado
    end
    
    mock_http.verify
    mock_response.verify
  end

  # Teste para Notificacoes::Convites
  test "notificar_novo_convite deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Convites.notificar_novo_convite(@convite)
        end
      end
    end
  end

  test "notificar_convite_aceito deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Convites.notificar_convite_aceito(@apoiador)
        end
      end
    end
  end

  # Teste para Notificacoes::Visitas
  test "notificar_nova_visita deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Visitas.notificar_nova_visita(@visita)
        end
      end
    end
  end

  test "notificar_visita_cancelada deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Visitas.notificar_visita_cancelada(@visita)
        end
      end
    end
  end

  # Teste para Notificacoes::Apoiadores
  test "notificar_novo_apoiador deve chamar Lideranca" do
    Mensageria::Lideranca.stub :notificar, true do
      assert_nothing_raised do
        Mensageria::Notificacoes::Apoiadores.notificar_novo_apoiador(@apoiador)
      end
    end
  end

  # Teste para Notificacoes::Eventos
  test "notificar_novo_evento deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Eventos.notificar_novo_evento(@evento)
        end
      end
    end
  end

  test "notificar_atualizacao_evento deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Lideranca.stub :notificar, true do
        assert_enqueued_with(job: SendWhatsappJob) do
          Mensageria::Notificacoes::Eventos.notificar_atualizacao_evento(@evento)
        end
      end
    end
  end

  # Teste para Notificacoes::Comunicados
  test "enviar_para_apoiador deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      assert_enqueued_with(job: SendWhatsappJob) do
        Mensageria::Notificacoes::Comunicados.enviar_para_apoiador(@comunicado, @apoiador)
      end
    end
  end

  test "notificar_participante deve enfileirar SendWhatsappJob" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      assert_enqueued_with(job: SendWhatsappJob) do
        Mensageria::Notificacoes::Eventos.notificar_participante(@evento, @apoiador)
      end
    end
  end

  # Teste para Mensagens::Convites
  test "Mensagens::Convites deve usar BASE_URL correta" do
    ENV['BASE_URL'] ||= "http://localhost:3000"
    texto = Mensageria::Mensagens::Convites.novo_convite(@convite, @apoiador)
    assert_includes texto, ENV['BASE_URL']
    assert_includes texto, "/convite/aceitar/#{@convite.id}"
  end

  # Teste para Helpers
  test "Helpers.format_phone_number deve formatar corretamente" do
    assert_equal "5596991234567", Mensageria::Helpers.format_phone_number("96991234567")
    assert_equal "5596991234567", Mensageria::Helpers.format_phone_number("5596991234567")
    assert_equal "5596991234567", Mensageria::Helpers.format_phone_number("(96) 99123-4567")
    assert_nil Mensageria::Helpers.format_phone_number(nil)
  end

  # Teste para Lideranca
  test "Lideranca.buscar_hierarquia deve retornar lista de lideres" do
    ana = apoiadores(:apoiador_1)
    lideres = Mensageria::Lideranca.buscar_hierarquia(ana)
    
    assert_includes lideres, apoiadores(:lider_1)
    assert_includes lideres, apoiadores(:coordenador_geral_1)
    assert_includes lideres, apoiadores(:joao_candidato)
    assert_equal lideres.uniq.length, lideres.length
  end
end
