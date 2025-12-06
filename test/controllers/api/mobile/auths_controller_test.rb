require "test_helper"

module Api
  module Mobile
    class AuthsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @apoiador = apoiadores(:ana_apoiadora)
        # Garante um número conhecido para os testes
        @apoiador.update!(whatsapp: "5596991120579")
      end

      test "deve retornar erro se whatsapp não for fornecido" do
        post "/api/mobile/auth/login"
        assert_response :bad_request
        json_response = JSON.parse(response.body)
        assert_equal "WhatsApp é obrigatório", json_response["error"]
      end

      test "deve retornar erro se apoiador não for encontrado" do
        post "/api/mobile/auth/login", params: { whatsapp: "00000000000" }
        assert_response :not_found
        json_response = JSON.parse(response.body)
        assert_equal "Número não encontrado", json_response["error"]
      end

      test "deve realizar login com sucesso se apoiador existir (param whatsapp)" do
        # Mockar o envio de mensagem
        mock = Minitest::Mock.new
        mock.expect :call, nil, [@apoiador]

        Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, mock do
          post "/api/mobile/auth/login", params: { whatsapp: @apoiador.whatsapp }
          assert_response :ok
          json_response = JSON.parse(response.body)
          assert_equal "Link enviado com sucesso", json_response["message"]
        end
        
        mock.verify
        
        # Verificar se gerou código
        @apoiador.reload
        assert_not_nil @apoiador.verification_code
      end

      test "deve realizar login com sucesso usando whatsappNumber (param alternativo)" do
        mock = Minitest::Mock.new
        mock.expect :call, nil, [@apoiador]

        Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, mock do
          post "/api/mobile/auth/login", params: { whatsappNumber: @apoiador.whatsapp }
          assert_response :ok
        end
        
        mock.verify
      end

      test "deve normalizar o número e encontrar o apoiador" do
        # O apoiador tem "5596991120579"
        # Enviamos "96991120579" (sem 55) - O format_chatbot_number deve corrigir para 5596991120579
        
        mock = Minitest::Mock.new
        mock.expect :call, nil, [@apoiador]

        Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, mock do
          post "/api/mobile/auth/login", params: { whatsapp: "96991120579" }
          assert_response :ok
        end
        
        mock.verify
      end
      
      test "deve normalizar número vindo do chatbot sem nono digito e encontrar apoiador" do
        # O apoiador tem "5596991120579"
        # Enviamos "9691120579" (sem 9 e sem 55) - O format_chatbot_number deve corrigir
        
        mock = Minitest::Mock.new
        mock.expect :call, nil, [@apoiador]

        Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, mock do
          post "/api/mobile/auth/login", params: { whatsapp: "9691120579" }
          assert_response :ok
        end
        
        mock.verify
      end
    end
  end
end
