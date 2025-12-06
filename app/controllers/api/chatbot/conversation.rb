# devemos remover acentos, pontiacoes e deixar apenas o texto em message
# se a mensagem for "OLA" ou "OLÁ" ou "olá" ou "O lá" deve ser tratada como a mesma mensagem
# entao essa funcao faz essa normalizacao da mensagem
# removendo acentos, pontuacoes e deixando tudo em maiusculo
# exemplo de uso:
# mensagem "OLA" sera enviado uma mensagem com um menu com as opcoes do chatbot
# coma as opcoes:
# 0 - Acessar o Sistema
# 1 - Convidar um apoiador
# 2 - Eventos de Hoje
# 3 - Minhas Visistas
# 4 - Conhecer mais sobre o IVONE
# 5 - Falar com um atendente
# qualquer outra mensagem sera respondida com uma mensagem padrão
# entao podemos receber 6 tipose de mensagens OLA, 0, 1, 2, 3, 4, 5
# e qualquer outra mensagem sera respondida com a mensagem padrão
# usaremos a mensageria para mandar as mensgens

# caso seja 0, enviaremos o link de acesso ao sistema
# no modelo Apoiador # Gera um código de 6 dígitos, salva e envia via WhatsApp
#  def gerar_codigo_acesso!(enviar_whatsapp: true)
#
# caso seja 1 mandaremos uma mensagem pedindo que envie o contato do apoiador
# caso seja 2 mandaremos os eventos do dia para o apoiador
# caso seja 3 mandaremos as visitas agendadas para o apoiador
# caso seja 4 mandaremos uma mensagem com informacoes sobre o IVONE
# caso seja 5 mandaremos uma mensagem informando que um atendente entrara em contato
# caso seja qualquer outra mensagem mandaremos a mensagem padrão

module Api
  module Chatbot
    class Conversation
      class << self
        def process(apoiador, message)
          # Extrai o texto da mensagem considerando diferentes formatos do WhatsApp
          raw_text = message["conversation"] ||
                     message["text"] ||
                     message.dig("extendedTextMessage", "text") ||
                     ""

          texto = normalize_message(raw_text)

          case texto
          when "OLA"
            enviar_menu_inicial(apoiador)
          when "0"
            enviar_link_acesso_sistema(apoiador)
          when "1"
            solicitar_contato_apoiador(apoiador)
          when "2"
            enviar_eventos_do_dia(apoiador)
          when "3"
            enviar_visitas_agendadas(apoiador)
          when "4"
            enviar_informacoes_ivone(apoiador)
          when "5"
            informar_atendente_entrara_em_contato(apoiador)
          else
            enviar_mensagem_padrao(apoiador)
          end
        end

        private

        def normalize_message(text)
          return "" if text.blank?

          I18n.transliterate(text).upcase.gsub(/[^A-Z0-9]/, "")
        end
        def enviar_menu_inicial(apoiador)
          image = ENV.fetch("IMAGE_IVI_AVATAR", nil)
          Rails.logger.info "Chatbot: Enviando menu inicial para #{apoiador.name}. Imagem: #{image.inspect}"

          mensagem = I18n.t("mensagens.chatbot.menu_inicial", nome: apoiador.name)

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem, imagem: image)
        end
        def enviar_link_acesso_sistema(apoiador)
          apoiador.gerar_codigo_acesso!(enviar_whatsapp: false)
          Mensageria::Notificacoes::Autenticacao.enviar_link_magico(apoiador)
        end
        def solicitar_contato_apoiador(apoiador)
          image = ENV.fetch("PASSO_A_PASSO_CONTATO", nil)
          mensagem = I18n.t("mensagens.chatbot.solicitar_contato")

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem, imagem: image)
        end
        def enviar_eventos_do_dia(apoiador)
          eventos = Evento.where(data: Date.current)
          if eventos.any?
            mensagem = I18n.t("mensagens.chatbot.eventos_hoje_titulo")
            eventos.each do |evento|
              mensagem += I18n.t("mensagens.chatbot.evento_item", nome: evento.nome, horario: evento.horario.strftime("%H:%M"))
            end
          else
            mensagem = I18n.t("mensagens.chatbot.sem_eventos")
          end

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem)
        end
        def enviar_visitas_agendadas(apoiador)
          # Busca visitas pendentes (assumindo que são as agendadas, já que não há coluna de data específica)
          visitas = apoiador.visitas_como_lider.where(status: "pendente")

          if visitas.any?
            mensagem = I18n.t("mensagens.chatbot.visitas_pendentes_titulo")
            visitas.each do |visita|
              mensagem += I18n.t("mensagens.chatbot.visita_item", nome: visita.apoiador.name, whatsapp: visita.apoiador.whatsapp, status: visita.status)
            end
          else
            mensagem = I18n.t("mensagens.chatbot.sem_visitas")
          end

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem)
        end
        def enviar_informacoes_ivone(apoiador)
          mensagem = I18n.t("mensagens.chatbot.informacoes_ivone")

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem)
        end
        def informar_atendente_entrara_em_contato(apoiador)
          mensagem = I18n.t("mensagens.chatbot.atendente_contato", nome: apoiador.name)

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem)
        end
        def enviar_mensagem_padrao(apoiador)
          mensagem = I18n.t("mensagens.chatbot.mensagem_padrao")

          Mensageria::Notificacoes::Chatbot.enviar_mensagem(apoiador, mensagem)
        end
      end
    end
  end
end
