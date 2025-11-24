# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Eventos
      class << self
        def notificar_novo_evento(evento)
          coordenador = evento.coordenador
          return unless coordenador

          # Envia convite para a rede do coordenador
          enviar_convite_para_rede(evento)

          # Notifica a liderança do coordenador (apenas informativo, sem link de participar)
          # Para liderança usamos uma mensagem genérica ou adaptamos o novo_evento para não ter link se apoiador for nil?
          # Vamos usar o novo_evento passando o próprio coordenador como "apoiador" alvo apenas para gerar o texto,
          # mas idealmente teríamos um texto específico para liderança.
          # Vou manter a lógica anterior de notificar liderança mas adaptando a chamada.

          mensagem_lideranca = Mensagens::Eventos.novo_evento(evento, coordenador) # Link para o próprio coordenador se quiser testar

          Lideranca.notificar(
            apoiador: coordenador,
            mensagem: mensagem_lideranca
          )

          # Loga no Redis
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(coordenador.whatsapp)
          Logger.log_mensagem_apoiador(
            fila: "mensageria",
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(coordenador.whatsapp),
            mensagem: mensagem_lideranca
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_evento: #{e.message}"
        end

        def enviar_convite_para_rede(evento)
          coordenador = evento.coordenador
          # Busca subordinados diretos e indiretos para convidar
          # Dependendo da regra de negócio, pode ser apenas diretos. Vamos assumir rede completa.
          rede = coordenador.todos_subordinados(incluir_indiretos: true)

          rede.each do |apoiador|
            texto = Mensagens::Eventos.novo_evento(evento, apoiador)
            imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

            Logger.log_mensagem_apoiador(
              fila: "mensageria",
              image_url: imagem_whatsapp,
              whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
              mensagem: texto
            )
          end
        end

        def notificar_participacao_confirmada(apoiadores_evento)
          evento = apoiadores_evento.evento
          apoiador = apoiadores_evento.apoiador
          organizador = evento.coordenador

          # 1. Confirmar para o apoiador
          texto_apoiador = Mensagens::Eventos.confirmacao_participacao_apoiador(evento, apoiador)
          imagem_apoiador = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          Logger.log_mensagem_apoiador(
            fila: "mensageria",
            image_url: imagem_apoiador,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto_apoiador
          )

          # 2. Notificar organizador
          if organizador
             texto_organizador = Mensagens::Eventos.notificacao_participacao_organizador(evento, apoiador)
             imagem_organizador = Utils::BuscaImagemWhatsapp.buscar(organizador.whatsapp)

             Logger.log_mensagem_apoiador(
               fila: "mensageria",
               image_url: imagem_organizador,
               whatsapp: Helpers.format_phone_number(organizador.whatsapp),
               mensagem: texto_organizador
             )
          end

          # 3. Notificar liderança superior
          texto_lideranca = Mensagens::Eventos.notificacao_participacao_lideranca(evento, apoiador)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: texto_lideranca
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar participação confirmada: #{e.message}"
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
            fila: "mensageria",
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
            fila: "mensageria",
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
