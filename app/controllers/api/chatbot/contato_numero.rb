# caso recebamos uma mensagem com numero de contato
# devemos criar um novo convite usando esse numero de contato
# antes devemos valida que o numero de contato é valido com a regex
# com um numeor valido devemos buscar o perfil no whatsapp
# se o perfil existir devemos criar um convite para esse numero com o nome do contato
# se o perfil nao existir devemos enviar uma mensagem informando que o numero é invalido
module Api
  module Chatbot
    class ContatoNumero
      class << self
        def process(apoiador, message)
          raw_text = message["conversation"] ||
                     message["text"] ||
                     message.dig("extendedTextMessage", "text") ||
                     ""

          texto = normalize_message(raw_text)
          numero_valido = verifica_se_numero_contato(texto)

          # Se não for um número válido, envia mensagem padrão (não entendeu o comando)
          unless numero_valido
            mensagem = I18n.t("mensagens.chatbot.mensagem_padrao")
            enviar_resposta(apoiador, mensagem)
            return
          end

          # Validações de duplicidade
          return if contact_already_registered?(apoiador, numero_valido)

          mensagem = I18n.t('mensagens.chatbot.identificacao_contato', numero: numero_valido)
          enviar_resposta(apoiador, mensagem)

          create_invite(apoiador, numero_valido)
        end

        private

        def normalize_message(text)
          text.to_s.strip
        end

        def verifica_se_numero_contato(telefone)
          numero_limpo = telefone.to_s.gsub(/\D/, "")
          return nil if numero_limpo.blank? || numero_limpo.length < 8

          # Normaliza para formato WhatsApp (55...)
          numero_normalizado = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(numero_limpo)

          # Garante tamanho mínimo (DDI + DDD + 9 dígitos = 13)
          return nil unless numero_normalizado.present? && numero_normalizado.length >= 13

          numero_normalizado
        end

        def contact_already_registered?(apoiador, numero)
          if Apoiador.exists?(whatsapp: numero)
            enviar_resposta(apoiador, I18n.t("mensagens.chatbot.ja_cadastrado"))
            return true
          end

          if (convite = Convite.where(whatsapp: numero).where.not(status: "recusado").first)
            enviar_resposta(apoiador, I18n.t("mensagens.chatbot.convite_existente", status: convite.status))
            return true
          end

          false
        end

        def create_invite(apoiador, numero)
          perfil = Utils::BuscaPerfilWhatsapp.buscar(numero)
          nome_contato = perfil&.dig(:name).presence

          if nome_contato
            convite = Convite.new(
              nome: nome_contato,
              whatsapp: numero,
              enviado_por: apoiador,
              status: "pendente"
            )

            if convite.save
              imagem_url = perfil&.dig(:picture)
              texto = I18n.t("mensagens.chatbot.convite_sucesso", nome_apoiador: apoiador.name, nome_convidado: nome_contato)
              enviar_resposta(apoiador, texto, image_url: imagem_url)
            else
              enviar_resposta(apoiador, I18n.t("mensagens.chatbot.erro_convite", erros: convite.errors.full_messages.join(", ")))
            end
          else
            # Mantendo a regra de negócio original: se não achar nome, pede para criar manualmente
            mensagem = I18n.t('mensagens.chatbot.nome_nao_encontrado')
            enviar_resposta(apoiador, mensagem)
            apoiador.gerar_codigo_acesso!(enviar_whatsapp: false)
            Mensageria::Notificacoes::Autenticacao.enviar_link_magico(apoiador)
          end
        end

        def enviar_resposta(apoiador, texto, image_url: nil)
          SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: texto, image_url: image_url)
        end
      end
    end
  end
end
#
