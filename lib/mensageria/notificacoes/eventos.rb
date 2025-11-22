# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Eventos
      class << self
        def notificar_novo_evento(evento)
          coordenador = evento.coordenador
          return unless coordenador

          mensagem = Mensagens::Eventos.novo_evento(evento)
          
          # Notifica a liderança do coordenador
          Lideranca.notificar(
            apoiador: coordenador,
            mensagem: mensagem
          )

          # Loga no Redis (que é o requisito de "gravar mensagem no channel mensageria")
          # Aqui assumimos que queremos logar a ação do coordenador
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(coordenador.whatsapp)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(coordenador.whatsapp),
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_evento: #{e.message}"
        end

        def notificar_atualizacao_evento(evento)
          coordenador = evento.coordenador
          return unless coordenador

          mensagem = Mensagens::Eventos.evento_atualizado(evento)

          # Notifica a liderança
          Lideranca.notificar(
            apoiador: coordenador,
            mensagem: mensagem
          )

          # Loga no Redis
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(coordenador.whatsapp)
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(coordenador.whatsapp),
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_atualizacao_evento: #{e.message}"
        end

        def notificar_participante(evento, apoiador)
          mensagem = Mensagens::Eventos.novo_evento(evento)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar participante #{apoiador.id} do evento #{evento.id}: #{e.message}"
        end
      end
    end
  end
end
