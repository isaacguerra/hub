# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Apoiadores
      class << self
        def notificar_novo_apoiador(apoiador)
          # Não notifica se foi criado via convite (já tratado em Convites)
          return if criado_por_convite?(apoiador)

          mensagem = Mensagens::Apoiadores.novo_apoiador(apoiador)

          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_novo_apoiador: #{e.message}"
        end

        def notificar_mudanca_funcao(apoiador, funcao_id_anterior)
          funcao_anterior = Funcao.find_by(id: funcao_id_anterior)
          
          mensagem = Mensagens::Apoiadores.mudanca_funcao(apoiador, funcao_anterior)

          Lideranca.notificar(
            apoiador: apoiador,
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro em notificar_mudanca_funcao: #{e.message}"
        end

        private

        def criado_por_convite?(apoiador)
          # Verifica se foi criado recentemente (less than 1 minute ago)
          # e se existe um convite aceito com mesmo whatsapp
          return false unless apoiador.created_at > 1.minute.ago

          Convite.exists?(whatsapp: apoiador.whatsapp, status: 'aceito')
        end
      end
    end
  end
end
