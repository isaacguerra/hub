# apos app/controllers/api/chatbot/webhook.rb ser processado
# receberomos o apoiador e a mensagem
# entao essa funcao inicia o processamento do chatbot para esse apoiador e mensagem
# usaremos o switch case para tratar os diferentes tipos de mensagens_type(conversation e contactMessage) e mensagem
module Api
  module Chatbot
    class ChatbotStart
      def self.start(apoiador:, message_data:)
        message_type = message_data[:message_type]
        content = message_data[:message_content]

        case message_type
        when "conversation", "extendedTextMessage"
          # extendedTextMessage geralmente é texto também
          Api::Chatbot::Conversation.process(apoiador, content)
        when "contactMessage"
          Api::Chatbot::ContactMessage.process(apoiador, content)
        else
          Rails.logger.warn "Tipo de mensagem desconhecido ou não tratado no chatbot: #{message_type}"
        end
      end
    end
  end
end
