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
          called = true if apoiador == @apoiador && mensagem.include?("escolha uma das opções abaixo") && imagem == "http://example.com/avatar.png"
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "OLA" })
        end

        assert called, "enviar_mensagem should have been called with correct image"
      end

      test "should send menu for olá (normalized)" do
        ENV["IMAGE_IVI_AVATAR"] = "http://example.com/avatar.png"
        called = false

        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          imagem = kwargs[:imagem]
          called = true if apoiador == @apoiador && mensagem.include?("escolha uma das opções abaixo") && imagem == "http://example.com/avatar.png"
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
          called = true if mensagem.include?("envie o contato") && imagem == "http://example.com/contact.png"
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "1" })
        end

        assert called
      end

      test "should list pending visits for 3" do
        called = false
        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, **kwargs) {
          called = true if mensagem.include?("Você não tem visitas pendentes")
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "3" })
        end
        assert called
      end

      test "should send default message for unknown option" do
        called = false
        Mensageria::Notificacoes::Chatbot.stub :enviar_mensagem, ->(apoiador, mensagem, imagem: nil) {
          called = true
        } do
          Api::Chatbot::Conversation.process(@apoiador, { "text" => "999" })
        end

        assert called
      end
    end
  end
end
