require "test_helper"
require "minitest/mock"

module Api
  module Chatbot
    class ContactMessageTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        @apoiador = apoiadores(:joao_candidato)
        @new_contact_number = "5596988887777"
        @vcard = "BEGIN:VCARD\nVERSION:3.0\nFN:Novo Contato\nTEL;waid=#{@new_contact_number}:+#{@new_contact_number}\nEND:VCARD"
        @message = {
          "contactMessage" => {
            "displayName" => "Novo Contato",
            "vcard" => @vcard
          }
        }
      end

      test "should create invite for new contact" do
        # Mock Utils::BuscaPerfilWhatsapp
        mock_perfil = Minitest::Mock.new
        mock_perfil.expect :call, { name: "Novo Contato Real", picture: "http://example.com/pic.jpg" }, [ @new_contact_number ]

        # Mock SendWhatsappJob to avoid real calls
        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && image_url == "http://example.com/pic.jpg"
        } do
          Utils::BuscaPerfilWhatsapp.stub :buscar, mock_perfil do
            assert_difference "Convite.count", 1 do
              Api::Chatbot::ContactMessage.process(@apoiador, @message)
            end
          end
        end

        assert called, "SendWhatsappJob should have been called with correct image_url"

        convite = Convite.last
        assert_equal @new_contact_number, convite.whatsapp
        assert_equal "Novo Contato Real", convite.nome
        assert_equal @apoiador, convite.enviado_por
        assert_equal "pendente", convite.status

        assert_mock mock_perfil
      end

      test "should not create invite if already apoiador" do
        existing_apoiador = apoiadores(:coordenador_geral_1)
        vcard = "BEGIN:VCARD\nVERSION:3.0\nFN:Existente\nTEL;waid=#{existing_apoiador.whatsapp}:+#{existing_apoiador.whatsapp}\nEND:VCARD"
        message = { "contactMessage" => { "displayName" => "Existente", "vcard" => vcard } }

        # Mock SendWhatsappJob
        called = false
        SendWhatsappJob.stub :perform_later, ->(args) {
          called = true if args[:whatsapp] == @apoiador.whatsapp && args[:mensagem].include?("Esse contato já está cadastrado como apoiador!")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContactMessage.process(@apoiador, message)
          end
        end

        assert called, "SendWhatsappJob should have been called with correct message"
      end

      test "should not create invite if invite exists (pending)" do
        Convite.create!(nome: "Teste", whatsapp: @new_contact_number, enviado_por: @apoiador, status: "pendente")

        # Mock SendWhatsappJob
        called = false
        SendWhatsappJob.stub :perform_later, ->(whatsapp:, mensagem:, image_url: nil) {
          called = true if whatsapp == @apoiador.whatsapp && mensagem.include?("Já existe um convite ativo para esse contato (Status: pendente)")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContactMessage.process(@apoiador, @message)
          end
        end

        assert called
      end

      test "should create invite if previous invite was refused" do
        Convite.create!(nome: "Teste Recusado", whatsapp: @new_contact_number, enviado_por: @apoiador, status: "recusado")

        # Mock Utils::BuscaPerfilWhatsapp
        mock_perfil = Minitest::Mock.new
        mock_perfil.expect :call, { name: "Novo Contato Real", picture: nil }, [ @new_contact_number ]

        SendWhatsappJob.stub :perform_later, true do
          Utils::BuscaPerfilWhatsapp.stub :buscar, mock_perfil do
            assert_difference "Convite.count", 1 do
              Api::Chatbot::ContactMessage.process(@apoiador, @message)
            end
          end
        end

        assert_mock mock_perfil
      end

      test "should handle invalid vcard" do
        message = { "contactMessage" => { "displayName" => "Invalid", "vcard" => "" } }

        # Mock SendWhatsappJob
        called = false
        SendWhatsappJob.stub :perform_later, ->(args) {
          called = true if args[:whatsapp] == @apoiador.whatsapp && args[:mensagem].include?("Não consegui identificar")
        } do
          assert_no_difference "Convite.count" do
            Api::Chatbot::ContactMessage.process(@apoiador, message)
          end
        end

        assert called
      end
    end
  end
end
