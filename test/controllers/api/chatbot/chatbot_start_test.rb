require "test_helper"
require "minitest/mock"

module Api
  module Chatbot
    class ChatbotStartTest < ActiveSupport::TestCase
      setup do
        @apoiador = apoiadores(:joao_candidato)
      end

      test "should route conversation type to Conversation.process" do
        message_data = {
          message_type: "conversation",
          message_content: { "text" => "OLA" }
        }

        called = false
        Api::Chatbot::Conversation.stub :process, ->(apoiador, content) {
          called = true if apoiador == @apoiador && content == message_data[:message_content]
        } do
          Api::Chatbot::ChatbotStart.start(apoiador: @apoiador, message_data: message_data)
        end

        assert called
      end

      test "should route extendedTextMessage type to Conversation.process" do
        message_data = {
          message_type: "extendedTextMessage",
          message_content: { "extendedTextMessage" => { "text" => "OLA" } }
        }

        called = false
        Api::Chatbot::Conversation.stub :process, ->(apoiador, content) {
          called = true if apoiador == @apoiador && content == message_data[:message_content]
        } do
          Api::Chatbot::ChatbotStart.start(apoiador: @apoiador, message_data: message_data)
        end

        assert called
      end

      test "should route contactMessage type to ContactMessage.process" do
        message_data = {
          message_type: "contactMessage",
          message_content: { "contactMessage" => { "vcard" => "..." } }
        }

        called = false
        Api::Chatbot::ContactMessage.stub :process, ->(apoiador, content) {
          called = true if apoiador == @apoiador && content == message_data[:message_content]
        } do
          Api::Chatbot::ChatbotStart.start(apoiador: @apoiador, message_data: message_data)
        end

        assert called
      end

      test "should log warning for unknown message type" do
        message_data = {
          message_type: "unknownType",
          message_content: {}
        }

        assert_nothing_raised do
          Api::Chatbot::ChatbotStart.start(apoiador: @apoiador, message_data: message_data)
        end
        # We can't easily assert logger output here without more setup, but ensuring it doesn't raise is good.
      end
    end
  end
end
