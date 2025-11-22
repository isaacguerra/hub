# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Comunicados
      class << self
        def notificar_novo_comunicado(comunicado)
          # Publicar evento no canal mensageria
          payload = {
            event: "novo_comunicado",
            data: {
              id: comunicado.id,
              titulo: comunicado.titulo,
              mensagem: comunicado.mensagem,
              lider_id: comunicado.lider_id,
              lider_nome: comunicado.lider&.nome,
              data: comunicado.data,
              created_at: comunicado.created_at
            }
          }

          Rails.logger.info "Publicando no Redis channel 'mensageria': #{payload.to_json}"
          Mensageria::RedisClient.publish("mensageria", payload.to_json)

          lider = comunicado.lider
          return unless lider

          # A notificação dos apoiadores é feita via callback no modelo ComunicadoApoiador
          # chamando o método enviar_para_apoiador.

          # Notificar a hierarquia do líder que criou o comunicado
          mensagem_lideranca = Mensagens::Comunicados.notificacao_lideranca(comunicado)

          Lideranca.notificar(
            apoiador: lider,
            mensagem: mensagem_lideranca
          )

        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_comunicado: #{e.message}"
        end

        def enviar_para_apoiador(comunicado, apoiador)
          texto = Mensagens::Comunicados.novo_comunicado(comunicado)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          Logger.log_mensagem_apoiador(
            fila: "mensageria",
            image_url: imagem_whatsapp,
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao enviar comunicado #{comunicado.id} para apoiador #{apoiador.id}: #{e.message}"
        end
      end
    end
  end
end
