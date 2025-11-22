# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Visitas
      class << self
        # Notifica sobre uma nova visita agendada
        #
        # Envia mensagem para:
        # - Apoiador que receberá a visita
        # - Líder que fará a visita
        # - Liderança do apoiador
        def notificar_nova_visita(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)

          return unless apoiador && lider

          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          texto = Mensagens::Visitas.nova_visita(visita)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto
          )

          texto_lider = Mensagens::Visitas.nova_visita_lider(visita)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(lider.whatsapp),
            mensagem: texto_lider
          )

          mensagem_lideranca = Mensagens::Visitas.notificacao_lideranca_nova_visita(visita)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem_lideranca,
            image_whatsapp: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_nova_visita: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        # Notifica sobre uma visita realizada
        #
        # Envia mensagem para:
        # - Apoiador que recebeu a visita
        # - Liderança do apoiador
        def notificar_visita_realizada(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)

          return unless apoiador && lider

          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          texto = Mensagens::Visitas.visita_realizada(visita)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto
          )

          mensagem_lideranca = Mensagens::Visitas.notificacao_lideranca_visita_realizada(visita)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem_lideranca,
            image_whatsapp: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_visita_realizada: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        # Notifica sobre cancelamento de visita
        #
        # Envia mensagem para:
        # - Apoiador que receberia a visita
        # - Liderança do apoiador
        def notificar_visita_cancelada(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)

          return unless apoiador && lider

          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          texto = Mensagens::Visitas.visita_cancelada(visita)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto
          )

          mensagem_lideranca = Mensagens::Visitas.notificacao_lideranca_visita_cancelada(visita)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem_lideranca,
            image_whatsapp: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_visita_cancelada: #{e.message}"
        end
      end
    end
  end
end
