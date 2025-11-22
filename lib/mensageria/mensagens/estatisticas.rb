# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Estatisticas
      class << self
        # Gera estatísticas de apoiadores agrupadas por função
        def gerar_apoiadores
          estatisticas = Apoiador.group(:funcao_id).count

          linhas = estatisticas.map do |funcao_id, total|
            funcao = Funcao.find_by(id: funcao_id)
            funcao_name = funcao ? funcao.name : 'Sem Função'
            "• #{funcao_name}: #{total}"
          end

          "📊 *Estatísticas de Apoiadores:*\n\n#{linhas.join("\n")}"
        end

        # Gera estatísticas de convites agrupadas por status
        def gerar_convites
          estatisticas = Convite.group(:status).count

          linhas = estatisticas.map do |status, total|
            "• #{status}: #{total}"
          end

          "📊 *Estatísticas de Convites:*\n\n#{linhas.join("\n")}"
        end

        # Gera estatísticas de visitas agrupadas por status
        def gerar_visitas
          estatisticas = Visita.group(:status).count

          linhas = estatisticas.map do |status, total|
            "• #{status}: #{total}"
          end

          "📊 *Estatísticas de Visitas:*\n\n#{linhas.join("\n")}"
        end
      end
    end
  end
end
