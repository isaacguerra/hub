module Mensageria
  module Mensagens
    module Chatbot
      class << self
        def notificar_numero_nao_cadastrado(nome)
          I18n.t("mensagens.chatbot.nao_cadastrado", nome: nome)
        end
      end
    end
  end
end

module Mensageria
  module Notificacoes
    module Chatbot
      class << self
        def enviar_mensagem(apoiador, mensagem, imagem: nil)
          SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: mensagem, image_url: imagem, projeto_id: apoiador.projeto_id)
        end

        def notificar_numero_nao_cadastrado(whatsapp, nome)
          mensagem = Mensageria::Mensagens::Chatbot.notificar_numero_nao_cadastrado(nome)
          SendWhatsappJob.perform_later(whatsapp: whatsapp, mensagem: mensagem, projeto_id: Current.projeto&.id)
        end
      end
    end
  end
end
