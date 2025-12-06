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
        rede = Utils::RedeApoiador.busca_rede(apoiador.id)
        return unless rede

        destinatarios = []
        destinatarios << rede[:lider] if rede[:lider]
        destinatarios.concat(rede[:coordenadores]) if rede[:coordenadores]

        # Remove duplicidades pelo ID
        destinatarios.uniq! { |d| d[:id] }

        destinatarios.each do |destinatario|
          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(destinatario[:whatsapp]),
            mensagem: mensagem,
            image_url: image_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao notificar líder #{destinatario[:name]}: #{e.message}"
        end
      end
    end
  end
end
