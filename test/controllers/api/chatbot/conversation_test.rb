require "test_helper"
require "minitest/mock"

module Api
  module Chatbot
    class ConversationTest < ActiveSupport::TestCase
      setup do
        @apoiador = apoiadores(:joao_candidato)
      end

      test "should send menu for OLA" do
        ENV["IMAGE_IVI_AVATAR"] = "https://app.ivonechagas.com.br/ivi_avatar.jpg"
        called = false

        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          imagem = kwargs[:imagem]
          # Verifica se a mensagem é a traduzida (I18n)
          expected_msg = I18n.t("mensagens.chatbot.menu_inicial", nome: @apoiador.name)
          called = true if apoiador == @apoiador && mensagem == expected_msg && imagem == "https://app.ivonechagas.com.br/ivi_avatar.jpg"
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "OLA" })
        end

        assert called, "enviar_mensagem should have been called with correct image"
      end

      test "should send menu for olá (normalized)" do
        ENV["IMAGE_IVI_AVATAR"] = "https://app.ivonechagas.com.br/ivi_avatar.jpg"
        called = false

        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          imagem = kwargs[:imagem]
          expected_msg = I18n.t("mensagens.chatbot.menu_inicial", nome: @apoiador.name)
          called = true if apoiador == @apoiador && mensagem == expected_msg && imagem == "https://app.ivonechagas.com.br/ivi_avatar.jpg"
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "olá" })
        end

        assert called, "enviar_mensagem should have been called with correct image"
      end



      test "should generate access code for 0" do
        called = false
        # Stubbing the method on the instance
        @apoiador.stub :gerar_codigo_acesso!, ->(args) { called = true } do
           # Also need to stub Mensageria::Notificacoes::Autenticacao.enviar_link_magico
           Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, true do
             Api::Chatbot::Conversation.process(@apoiador, { "text" => "0" })
           end
        end
        assert called, "gerar_codigo_acesso! should have been called"
      end

      test "should ask for contact for 1" do
        ENV["PASSO_A_PASSO_CONTATO"] = "http://example.com/contact.png"
        called = false

        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          imagem = kwargs[:imagem]
          expected_msg = I18n.t("mensagens.chatbot.solicitar_contato")
          called = true if mensagem == expected_msg && imagem == "http://example.com/contact.png"
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "1" })
        end

        assert called
      end

      test "should list pending visits for 3" do
        called = false
        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          expected_msg = I18n.t("mensagens.chatbot.sem_visitas")
          called = true if mensagem == expected_msg
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "3" })
        end
        assert called
      end

      test "should send ranking for 6" do
        # Mock Gamification::RankingService to return some data
        daily_winner = { apoiador: @apoiador, points: 50 }
        
        Gamification::RankingService.stub :winner, daily_winner do
          # We expect multiple messages to be sent.
          called_count = 0
          Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
            called_count += 1
          } do
            Api::Chatbot::Conversation.process(@apoiador, { "text" => "6" })
          end
          
          assert called_count >= 1
        end
      end

      test "should send default message for unknown option" do
        called = false
        # Since unknown options are delegated to ContatoNumero which uses SendWhatsappJob directly
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && mensagem == I18n.t("mensagens.chatbot.mensagem_padrao")
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "999" })
        end

        assert called
      end
    end
  end
end
