module RedeApoiadores
  extend ActiveSupport::Concern

  included do
    # Retorna toda a rede acima do apoiador:
    # Candidato, Coordenadores Gerais, Coordenadores de Municipio,
    # Coordenadores de Regiao, Coordenadores de Bairro.
    def coordenadores
      return Apoiador.none if id.blank?

      conn = Apoiador.all

      coords = Apoiador.none

      # Coordenadores globais
      coords = coords.or(Apoiador.where(funcao_id: [Funcao::CANDIDATO_ID, Funcao::COORDENADOR_GERAL_ID]))

      # Coordenadores por localidade
      if municipio_id.present?
        coords = coords.or(Apoiador.where(funcao_id: Funcao::COORDENADOR_MUNICIPAL_ID, municipio_id: municipio_id))
      end

      if regiao_id.present?
        coords = coords.or(Apoiador.where(funcao_id: Funcao::COORDENADOR_REGIONAL_ID, regiao_id: regiao_id))
      end

      if bairro_id.present?
        coords = coords.or(Apoiador.where(funcao_id: Funcao::COORDENADOR_BAIRRO_ID, bairro_id: bairro_id))
      end

      # Exclui o próprio apoiador e garante distinct
      coords = coords.where.not(id: id).distinct

      coords
    end

    # Retorna os liderados baseados na função do apoiador
    def liderados
      return Apoiador.none if id.blank?

      case funcao_id
      when Funcao::CANDIDATO_ID, Funcao::COORDENADOR_GERAL_ID
        Apoiador.where.not(id: id)
      when Funcao::COORDENADOR_MUNICIPAL_ID
        municipio_id.present? ? Apoiador.where(municipio_id: municipio_id).where.not(id: id) : Apoiador.none
      when Funcao::COORDENADOR_REGIONAL_ID
        regiao_id.present? ? Apoiador.where(regiao_id: regiao_id).where.not(id: id) : Apoiador.none
      when Funcao::COORDENADOR_BAIRRO_ID
        bairro_id.present? ? Apoiador.where(bairro_id: bairro_id).where.not(id: id) : Apoiador.none
      else
        todos_subordinados_relation
      end
    end

    # Retorna uma ActiveRecord::Relation com todos os subordinados diretos e indiretos
    # Usa CTE recursiva em PostgreSQL para performance; fallback para array-based quando não disponível.
    def todos_subordinados_relation
      return Apoiador.none if id.blank?

      adapter = ActiveRecord::Base.connection.adapter_name.downcase
      if adapter.include?("postgresql")
        quoted_id = ActiveRecord::Base.connection.quote(id)
        sql = <<-SQL.squish
          WITH RECURSIVE subs AS (
            SELECT id FROM apoiadores WHERE lider_id = #{quoted_id}
            UNION ALL
            SELECT a.id FROM apoiadores a JOIN subs s ON a.lider_id = s.id
          )
          SELECT id FROM subs
        SQL

        rows = ActiveRecord::Base.connection.exec_query(sql).rows.flatten
        return Apoiador.where(id: rows)
      else
        # Fallback: usa método existente que retorna array
        ids = todos_subordinados(incluir_indiretos: true).map(&:id)
        Apoiador.where(id: ids)
      end
    end

    # Retorna a rede completa: coordenadores, lider direto e liderados
    def rede_completa
      {
        coordenadores: coordenadores,
        lider: lider,
        liderados: liderados
      }
    end
  end
end
