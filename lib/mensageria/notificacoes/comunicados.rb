# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Comunicados
      class << self
        def notificar_novo_comunicado(comunicado)
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
          texto = Mensagens::Comunicados.novo_comunicado(comunicado, apoiador)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto,
            image_url: imagem_whatsapp,
            projeto_id: apoiador.projeto_id
          )

          # Marcar como recebido para pontuar
          comunicado_apoiador = ComunicadoApoiador.find_by(comunicado: comunicado, apoiador: apoiador)
          comunicado_apoiador&.update(recebido: true)
        rescue StandardError => e
          Rails.logger.error "Erro ao enviar comunicado #{comunicado.id} para apoiador #{apoiador.id}: #{e.message}"
        end

        def notificar_engajamento(comunicado_apoiador)
          comunicado = comunicado_apoiador.comunicado
          apoiador = comunicado_apoiador.apoiador
          criador = comunicado.lider

          # 1. Confirmar para o apoiador
          texto_apoiador = Mensagens::Comunicados.confirmacao_leitura_apoiador(comunicado, apoiador)
          imagem_apoiador = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto_apoiador,
            image_url: imagem_apoiador,
            projeto_id: apoiador.projeto_id
          )

          # 2. Notificar criador do comunicado
          if criador
             texto_criador = Mensagens::Comunicados.notificacao_engajamento_criador(comunicado, apoiador)
             imagem_criador = Utils::BuscaImagemWhatsapp.buscar(criador.whatsapp)

             SendWhatsappJob.perform_later(
               whatsapp: Helpers.format_phone_number(criador.whatsapp),
               mensagem: texto_criador,
               image_url: imagem_criador,
               projeto_id: criador.projeto_id
             )
          end

          # 3. Notificar liderança superior
          texto_lideranca = Mensagens::Comunicados.notificacao_engajamento_lideranca(comunicado, apoiador)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: texto_lideranca
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar engajamento: #{e.message}"
        end
      end
    end
  end
end
