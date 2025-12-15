# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Convites
      class << self
        # Notifica sobre um novo convite criado
        #
        # Envia mensagem para:
        # - Convidado
        # - Liderança do apoiador que criou o convite
        def notificar_novo_convite(convite)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(convite.whatsapp)

          apoiador = Apoiador.includes(:funcao, :municipio).find_by(id: convite.enviado_por_id)

          unless apoiador
            Rails.logger.error "Apoiador não encontrado para o convite: #{convite.id}"
            return
          end

          texto = Mensagens::Convites.novo_convite(convite, apoiador)
          imagem_url = ENV["IMAGEM_CONVITE"]

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(convite.whatsapp),
            mensagem: texto,
            image_url: imagem_url,
            projeto_id: convite.projeto_id
          )

          mensagem_lideranca = Mensagens::Convites.notificacao_lideranca_novo_convite(convite, apoiador)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem_lideranca,
            image_whatsapp: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_convite: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        # Notifica sobre aceitação de convite
        #
        # Envia mensagem para:
        # - Apoiador que aceitou
        # - Líder direto do apoiador
        # - Liderança do apoiador
        def notificar_convite_aceito(apoiador)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)
          image_url = ENV["IMAGEM_CONVITE"]

          texto = Mensagens::Convites.convite_aceito(apoiador)
          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto,
            image_url: image_url,
            projeto_id: apoiador.projeto_id
          )

          # Busca a rede para identificar o líder direto
          rede = Utils::RedeApoiador.busca_rede(apoiador.id)

          if rede && rede[:lider]
            texto_lider = Mensagens::Convites.convite_aceito_lider(apoiador)
            SendWhatsappJob.perform_later(
              whatsapp: Helpers.format_phone_number(rede[:lider][:whatsapp]),
              mensagem: texto_lider,
              image_url: imagem_whatsapp,
              projeto_id: apoiador.projeto_id
            )
          end

          mensagem_lideranca = Mensagens::Convites.notificacao_lideranca_convite_aceito(apoiador)
          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem_lideranca,
            image_whatsapp: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_convite_aceito: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        # Notifica sobre recusa de convite
        #
        # Envia mensagem para:
        # - Liderança do apoiador que enviou o convite
        def notificar_convite_recusado(convite)
          apoiador = Apoiador.find_by(id: convite.enviado_por_id)
          return unless apoiador

          mensagem = Mensagens::Convites.notificacao_lideranca_convite_recusado(convite)

          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_convite_recusado: #{e.message}"
        end
      end
    end
  end
end
