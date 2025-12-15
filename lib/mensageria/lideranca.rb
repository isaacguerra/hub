# frozen_string_literal: true

module Mensageria
  module Lideranca
    class << self
      # Busca toda a hierarquia de liderança de um apoiador
      #
      # Retorna (quando aplicável):
      # - Líder direto
      # - Coordenador Municipal (funcaoId: 4)
      # - Coordenador Regional (funcaoId: 3)
      # - Coordenadores Gerais (funcaoId: 2)
      # - Candidatos (funcaoId: 1)
      def buscar_hierarquia(apoiador)
        # Utiliza a nova lógica centralizada no concern RedeApoiadores
        # Combina coordenadores e líder direto, removendo duplicatas e nulos
        (apoiador.coordenadores + [ apoiador.lider ]).compact.uniq
      end

      # Notifica toda a hierarquia de liderança
      def notificar(apoiador:, mensagem:, image_whatsapp: nil)
        lideres = buscar_hierarquia(apoiador)

        lideres.each do |lider|
            SendWhatsappJob.perform_later(
              whatsapp: Helpers.format_phone_number(lider.whatsapp),
              mensagem: mensagem,
              image_url: image_whatsapp,
              projeto_id: lider.projeto_id
            )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar líder #{lider.name}: #{e.message}"
        end
      end
    end
  end
end
