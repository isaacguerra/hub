# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Eventos
      class << self
        def notificar_novo_evento(evento)
          coordenador = evento.coordenador
          return unless coordenador

          # 1. Notificar Liderança (Sempre, sem filtros)
          # Notifica a hierarquia ascendente do coordenador
          # Usamos uma mensagem genérica ou a de novo evento
          mensagem_lideranca = Mensagens::Eventos.novo_evento(evento, coordenador)

          Lideranca.notificar(
            apoiador: coordenador,
            mensagem: mensagem_lideranca
          )

          # 2. Notificar Liderados (Com Filtros)
          # Busca destinatários baseados nos filtros definidos no evento
          destinatarios = evento.destinatarios_filtrados

          # Se o coordenador não for Candidato ou Coordenador Geral, talvez devêssemos restringir à rede dele?
          # Por enquanto, seguindo a solicitação, aplicamos os filtros sobre todos os apoiadores.
          # Mas vamos garantir que o próprio coordenador não receba a mensagem de "convite" duplicada se ele cair no filtro.
          # destinatarios = destinatarios.where.not(id: coordenador.id)

          destinatarios.find_each do |apoiador|
            texto = Mensagens::Eventos.novo_evento(evento, apoiador)
            imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

            SendWhatsappJob.perform_later(
              whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
              mensagem: texto,
              image_url: imagem_whatsapp,
              projeto_id: apoiador.projeto_id
            )
          end
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_evento: #{e.message}"
        end

        # Método antigo removido ou mantido se usado em outro lugar (parece que só era usado aqui)
        # def enviar_convite_para_rede(evento) ... end

        def notificar_participacao_confirmada(apoiadores_evento)
          evento = apoiadores_evento.evento
          apoiador = apoiadores_evento.apoiador
          organizador = evento.coordenador

          # 1. Confirmar para o apoiador
          texto_apoiador = Mensagens::Eventos.confirmacao_participacao_apoiador(evento, apoiador)
          imagem_apoiador = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto_apoiador,
            image_url: imagem_apoiador,
            projeto_id: apoiador.projeto_id
          )

          # 2. Notificar organizador
          if organizador
             texto_organizador = Mensagens::Eventos.notificacao_participacao_organizador(evento, apoiador)
             imagem_organizador = Utils::BuscaImagemWhatsapp.buscar(organizador.whatsapp)

             SendWhatsappJob.perform_later(
               whatsapp: Helpers.format_phone_number(organizador.whatsapp),
               mensagem: texto_organizador,
               image_url: imagem_organizador,
               projeto_id: organizador.projeto_id
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
          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(coordenador.whatsapp),
            mensagem: mensagem,
            image_url: imagem_whatsapp,
            projeto_id: coordenador.projeto_id
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_atualizacao_evento: #{e.message}"
        end

        def notificar_participante(evento, apoiador)
          mensagem = Mensagens::Eventos.novo_evento(evento, apoiador)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: mensagem,
            image_url: imagem_whatsapp,
            projeto_id: apoiador.projeto_id
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar participante #{apoiador.id} do evento #{evento.id}: #{e.message}"
        end
      end
    end
  end
end
