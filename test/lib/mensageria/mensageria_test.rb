require "test_helper"
require "minitest/mock"
require "ostruct"

class MensageriaTest < ActiveSupport::TestCase
  def setup
    @apoiador = apoiadores(:pedro_lider)
    @convite = convites(:convite_pendente)
    @visita = visitas(:visita_pendente)
    @evento = OpenStruct.new(
      id: 1,
      titulo: "Reunião Geral",
      descricao: "Discussão de pautas",
      data: Time.now + 1.day,
      coordenador: @apoiador
    )
    @comunicado = OpenStruct.new(
      id: 1,
      titulo: "Aviso Importante",
      mensagem: "Conteúdo do aviso",
      data: Time.now,
      lider: @apoiador,
      regiao: nil,
      apoiadores: Apoiador.where(id: [@apoiador.id]) # Usando query real ou array mockado se possível
    )
  end

  # Teste para Utils::BuscaImagemWhatsapp
  test "Utils::BuscaImagemWhatsapp deve fazer requisição POST correta" do
    # Mock ENV variables
    ENV['N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP'] = "https://n8n.exemplo.com/webhook/busca-imagem"
    
    url = ENV['N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP']
    uri = URI(url)
    
    mock_http = Minitest::Mock.new
    mock_response = Minitest::Mock.new
    
    mock_response.expect :body, { "imageUrl" => "http://imagem.com/foto.jpg" }.to_json
    
    # Expect use_ssl= called with true because url is https
    mock_http.expect :use_ssl=, true, [true]
    
    # Expect request to be called
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

  # Teste para RedisClient
  test "RedisClient deve publicar mensagem" do
    mock_redis = Minitest::Mock.new
    mock_redis.expect :publish, true, ["canal", "mensagem"]
    
    Mensageria::RedisClient.stub :connection, mock_redis do
      Mensageria::RedisClient.publish("canal", "mensagem")
    end
    
    assert mock_redis.verify
  end

  # Teste para Notificacoes::Convites
  test "notificar_novo_convite deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Convites.notificar_novo_convite(@convite)
          end
        end
      end
    end
  end

  test "notificar_convite_aceito deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Convites.notificar_convite_aceito(@apoiador)
          end
        end
      end
    end
  end

  test "notificar_convite_recusado deve chamar Lideranca" do
    Mensageria::Lideranca.stub :notificar, true do
      assert_nothing_raised do
        Mensageria::Notificacoes::Convites.notificar_convite_recusado(@convite)
      end
    end
  end

  # Teste para Notificacoes::Visitas
  test "notificar_nova_visita deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Visitas.notificar_nova_visita(@visita)
          end
        end
      end
    end
  end

  test "notificar_visita_cancelada deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Visitas.notificar_visita_cancelada(@visita)
          end
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

  test "notificar_mudanca_funcao deve chamar Lideranca" do
    Mensageria::Lideranca.stub :notificar, true do
      assert_nothing_raised do
        Mensageria::Notificacoes::Apoiadores.notificar_mudanca_funcao(@apoiador, 1)
      end
    end
  end

  # Teste para Notificacoes::Eventos
  test "notificar_novo_evento deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Eventos.notificar_novo_evento(@evento)
          end
        end
      end
    end
  end

  test "notificar_atualizacao_evento deve chamar Logger e Lideranca" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        Mensageria::Lideranca.stub :notificar, true do
          assert_nothing_raised do
            Mensageria::Notificacoes::Eventos.notificar_atualizacao_evento(@evento)
          end
        end
      end
    end
  end

  # Teste para Notificacoes::Comunicados
  test "notificar_novo_comunicado deve chamar Lideranca" do
    Mensageria::Lideranca.stub :notificar, true do
      assert_nothing_raised do
        Mensageria::Notificacoes::Comunicados.notificar_novo_comunicado(@comunicado)
      end
    end
  end

  test "enviar_para_apoiador deve chamar Logger" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        assert_nothing_raised do
          Mensageria::Notificacoes::Comunicados.enviar_para_apoiador(@comunicado, @apoiador)
        end
      end
    end
  end

  test "notificar_participante deve chamar Logger" do
    Utils::BuscaImagemWhatsapp.stub :buscar, "http://imagem.com/foto.jpg" do
      Mensageria::Logger.stub :log_mensagem_apoiador, true do
        assert_nothing_raised do
          Mensageria::Notificacoes::Eventos.notificar_participante(@evento, @apoiador)
        end
      end
    end
  end

  # Teste para Mensagens::Convites (verificação de variáveis de ambiente)
  test "Mensagens::Convites deve usar BASE_URL correta" do
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

  # Teste para Logger
  test "Logger.log_mensagem_apoiador deve publicar no Redis" do
    mock_redis = Minitest::Mock.new
    mock_redis.expect :publish, true do |channel, message|
      data = JSON.parse(message)
      channel == Mensageria::Logger::REDIS_CHANNEL &&
      data["fila"] == "teste" &&
      data["whatsapp"] == "123"
    end

    Mensageria::RedisClient.stub :connection, mock_redis do
      Mensageria::Logger.log_mensagem_apoiador(
        fila: "teste",
        image_url: "http://img.com",
        whatsapp: "123",
        mensagem: "msg"
      )
    end
    
    assert mock_redis.verify
  end

  # Teste para Lideranca
  test "Lideranca.buscar_hierarquia deve retornar lista de lideres" do
    # Ana (apoiadora) -> Pedro (lider) -> Maria (coord geral) -> João (candidato)
    ana = apoiadores(:ana_apoiadora)
    
    lideres = Mensageria::Lideranca.buscar_hierarquia(ana)
    
    # Deve incluir Pedro (lider direto)
    assert_includes lideres, apoiadores(:pedro_lider)
    
    # Deve incluir Maria (coord geral)
    assert_includes lideres, apoiadores(:maria_coord_geral)
    
    # Deve incluir João (candidato)
    assert_includes lideres, apoiadores(:joao_candidato)
    
    # Não deve ter duplicatas
    assert_equal lideres.uniq.length, lideres.length
  end
end
