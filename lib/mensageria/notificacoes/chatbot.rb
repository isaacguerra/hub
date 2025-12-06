module Mensageria
  module Notificacoes
    module Chatbot
      class << self
        def enviar_mensagem(apoiador, mensagem, imagem: nil)
          SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: mensagem, image_url: imagem)
        end

        def notificar_numero_nao_cadastrado(whatsapp, nome)
          mensagem = "Olá #{nome}, seu número não está cadastrado em nossa base. Entre em contato com a administração."
          SendWhatsappJob.perform_later(whatsapp: whatsapp, mensagem: mensagem)
        end
      end
    end
  end
end
