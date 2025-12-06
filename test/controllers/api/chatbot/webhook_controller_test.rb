require "test_helper"
require "minitest/mock"

module Api
  module Chatbot
    class WebhookControllerTest < ActionDispatch::IntegrationTest
      include ActiveJob::TestHelper

      setup do
        @apoiador = apoiadores(:joao_candidato)
        @valid_payload = {
          "event" => "messages.upsert",
          "instance" => "ivone",
          "data" => {
            "key" => {
              "remoteJid" => "#{@apoiador.whatsapp}@s.whatsapp.net",
              "fromMe" => false
            },
            "pushName" => "João",
            "message" => {
              "conversation" => "OLA"
            },
            "messageType" => "conversation",
            "messageTimestamp" => 1234567890,
            "source" => "android"
          }
        }
      end

      test "should process webhook for existing apoiador" do
        # Mock ChatbotStart to ensure it's called
        called = false
        Api::Chatbot::ChatbotStart.stub :start, ->(args) {
          called = true if args[:apoiador] == @apoiador && args[:message_data].is_a?(Hash)
        } do
          # Envia o payload diretamente como params (simulando o webhook real)
          post api_chatbot_webhook_url, params: @valid_payload, as: :json
        end

        puts response.body unless response.successful?
        assert_response :success
        assert called, "ChatbotStart.start should have been called"
      end

      test "should notify when number not registered" do
        payload = @valid_payload.deep_dup
        payload["data"]["key"]["remoteJid"] = "5596999999999@s.whatsapp.net"

        # Mock Notificacoes::Chatbot
        mock = Minitest::Mock.new
        mock.expect :call, nil, [ "5596999999999", "João" ]

        Mensageria::Notificacoes::Chatbot.stub :notificar_numero_nao_cadastrado, mock do
          post api_chatbot_webhook_url, params: { body: payload }, as: :json
        end

        assert_response :success
        assert_mock mock
      end

      test "should return error for invalid whatsapp number" do
        payload = @valid_payload.deep_dup
        payload["data"]["key"]["remoteJid"] = "invalid"

        post api_chatbot_webhook_url, params: { body: payload }, as: :json
        assert_response :bad_request
      end
    end
  end
end
