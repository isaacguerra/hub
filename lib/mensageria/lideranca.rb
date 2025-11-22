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
        lideres = []
        ids_adicionados = Set.new

        adicionar_lider = lambda do |lider|
          if lider && !ids_adicionados.include?(lider.id)
            lideres << lider
            ids_adicionados.add(lider.id)
          end
        end

        # Líder direto
        if apoiador.lider_id.present?
          lider = Apoiador.includes(:funcao, :municipio, :bairro)
                          .find_by(id: apoiador.lider_id)
          adicionar_lider.call(lider)
        end

        # Coordenador Municipal (funcaoId: 4)
        coord_municipal = Apoiador.includes(:funcao, :municipio, :bairro)
                                   .find_by(funcao_id: 4, municipio_id: apoiador.municipio_id)
        adicionar_lider.call(coord_municipal)

        # Coordenador Regional (funcaoId: 3)
        coord_regional = Apoiador.includes(:funcao, :municipio, :bairro)
                                  .find_by(funcao_id: 3, regiao_id: apoiador.regiao_id)
        adicionar_lider.call(coord_regional)

        # Coordenadores Gerais (funcaoId: 2)
        coord_gerais = Apoiador.includes(:funcao, :municipio, :bairro)
                               .where(funcao_id: 2)
        coord_gerais.each { |coord| adicionar_lider.call(coord) }

        # Candidatos (funcaoId: 1)
        candidatos = Apoiador.includes(:funcao, :municipio, :bairro)
                             .where(funcao_id: 1)
        candidatos.each { |candidato| adicionar_lider.call(candidato) }

        lideres
      end

      # Notifica toda a hierarquia de liderança
      def notificar(apoiador:, mensagem:, image_whatsapp: nil)
        hierarquia = buscar_hierarquia(apoiador)

        hierarquia.each do |lider|
          Logger.log_mensagem_apoiador(
            fila: 'mensageria',
            image_url: image_whatsapp,
            whatsapp: Helpers.format_phone_number(lider.whatsapp),
            mensagem: mensagem
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar líder #{lider.name}: #{e.message}"
        end
      end
    end
  end
end
