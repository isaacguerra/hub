require "test_helper"
require "minitest/mock"

module Api
  module Chatbot
    class ContatoNumeroTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        @apoiador = apoiadores(:joao_candidato)
        @valid_number_text = "5596988887777"
        @invalid_number_text = "123"
        @message_valid = { "conversation" => @valid_number_text }
        @message_invalid = { "conversation" => @invalid_number_text }
      end

      test "should create invite for valid number text" do
        # Mock Utils::BuscaPerfilWhatsapp
        mock_perfil = Minitest::Mock.new
        mock_perfil.expect :call, { name: "Novo Contato Texto", picture: "http://example.com/pic.jpg" }, [ @valid_number_text ]

        # Mock SendWhatsappJob
        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && image_url == "http://example.com/pic.jpg"
        } do
          Utils::BuscaPerfilWhatsapp.stub :buscar, mock_perfil do
            assert_difference "Convite.count", 1 do
              Api::Chatbot::ContatoNumero.process(@apoiador, @message_valid)
            end
          end
        end

        assert called, "SendWhatsappJob should have been called with correct image_url"

        convite = Convite.last
        assert_equal @valid_number_text, convite.whatsapp
        assert_equal "Novo Contato Texto", convite.nome
        assert_equal @apoiador, convite.enviado_por
        assert_equal "pendente", convite.status

        assert_mock mock_perfil
      end

      test "should send default message for invalid number" do
        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && mensagem == I18n.t("mensagens.chatbot.mensagem_padrao")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContatoNumero.process(@apoiador, @message_invalid)
          end
        end

        assert called, "Should have sent default message for invalid number"
      end

      test "should not create invite if already apoiador" do
        existing_apoiador = apoiadores(:maria_coord_geral)
        message = { "conversation" => existing_apoiador.whatsapp }

        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && mensagem == I18n.t("mensagens.chatbot.ja_cadastrado")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContatoNumero.process(@apoiador, message)
          end
        end

        assert called
      end

      test "should not create invite if invite exists (pending)" do
        Convite.create!(nome: "Teste", whatsapp: @valid_number_text, enviado_por: @apoiador, status: "pendente", projeto_id: projetos(:default_project).id)

        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && mensagem == I18n.t("mensagens.chatbot.convite_existente", status: "pendente")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContatoNumero.process(@apoiador, @message_valid)
          end
        end

        assert called
      end

      test "should send manual link if name not found" do
        # Mock Utils::BuscaPerfilWhatsapp returning nil name
        mock_perfil = Minitest::Mock.new
        mock_perfil.expect :call, { name: nil, picture: nil }, [ @valid_number_text ]

        called_msg = false
        called_link = false

        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          if mensagem.include?("Não consegui encontrar o NOME")
            called_msg = true
          end
        } do
          Utils::BuscaPerfilWhatsapp.stub :buscar, mock_perfil do
            Mensageria::Notificacoes::Autenticacao.stub :enviar_link_magico, ->(apoiador) { called_link = true } do
               Api::Chatbot::ContatoNumero.process(@apoiador, @message_valid)
            end
          end
        end

        assert called_msg, "Should have sent 'Name not found' message"
        assert called_link, "Should have called enviar_link_magico"
        assert_mock mock_perfil
      end
    end
  end
end
