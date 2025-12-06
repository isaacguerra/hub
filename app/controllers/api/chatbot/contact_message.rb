

module Api
  module Chatbot
    class ContactMessage
      class << self
        def process(apoiador, message)
          # apoiador é o lider_id do convite que enviou o contato
          # na mensagem temos o contactMessage para quem sera enviado o convite
          contact_data = message["contactMessage"]
          return unless contact_data

          waid = extract_waid(contact_data["vcard"])
          unless waid
            return enviar_resposta(apoiador, "Não consegui identificar o número desse contato. Tente enviar novamente.")
          end

          numero = Utils::NormalizaNumeroWhatsapp.format(waid)
          return enviar_resposta(apoiador, "O número do contato parece inválido.") if numero.blank?

          return if contact_already_registered?(apoiador, numero)

          create_invite(apoiador, numero, contact_data["displayName"])
        end

        private

        def contact_already_registered?(apoiador, numero)
          if Apoiador.exists?(whatsapp: numero)
            enviar_resposta(apoiador, "Esse contato já está cadastrado como apoiador!")
            return true
          end

          # Verifica se existe convite PENDENTE ou ACEITO. Se foi recusado, permite criar outro.
          if (convite = Convite.where(whatsapp: numero).where.not(status: "recusado").first)
            enviar_resposta(apoiador, "Já existe um convite ativo para esse contato (Status: #{convite.status}).")
            return true
          end

          false
        end

        def create_invite(apoiador, numero, display_name)
          perfil = Utils::BuscaPerfilWhatsapp.buscar(numero)
          nome_final = perfil&.dig(:name).presence || display_name.presence || "Sem Nome"

          convite = Convite.new(
            nome: nome_final,
            whatsapp: numero,
            enviado_por: apoiador,
            status: "pendente"
          )

          if convite.save
            imagem_url = perfil&.dig(:picture)
            texto = "Parabéns #{apoiador.name}! Convite criado com sucesso para #{nome_final}!"
            enviar_resposta(apoiador, texto, image_url: imagem_url)
          else
            enviar_resposta(apoiador, "Erro ao criar convite: #{convite.errors.full_messages.join(', ')}")
          end
        end

        def extract_waid(vcard)
          return nil if vcard.blank?

          vcard.match(/waid=(\d+)/)&.[](1) ||
            vcard.match(/TEL.*:([+\d\s-]+)/)&.[](1)&.gsub(/\D/, "")
        end

        def enviar_resposta(apoiador, texto, image_url: nil)
          SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: texto, image_url: image_url)
        end
      end
    end
  end
end
