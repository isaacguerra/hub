module RedeApoiadores
  extend ActiveSupport::Concern

  included do
    # Retorna toda a rede acima do apoiador:
    # Candidato, Coordenadores Gerais, Coordenadores de Municipio,
    # Coordenadores de Regiao, Coordenadores de Bairro.
    def coordenadores
      # Busca coordenadores globais
      globais = Apoiador.where(funcao_id: [Funcao::CANDIDATO_ID, Funcao::COORDENADOR_GERAL_ID])

      # Busca coordenadores por localidade
      municipais = municipio_id ? Apoiador.where(funcao_id: Funcao::COORDENADOR_MUNICIPAL_ID, municipio_id: municipio_id) : Apoiador.none
      regionais = regiao_id ? Apoiador.where(funcao_id: Funcao::COORDENADOR_REGIONAL_ID, regiao_id: regiao_id) : Apoiador.none
      bairros = bairro_id ? Apoiador.where(funcao_id: Funcao::COORDENADOR_BAIRRO_ID, bairro_id: bairro_id) : Apoiador.none

      # Une, remove duplicidades e o próprio apoiador
      (globais + municipais + regionais + bairros).uniq.reject { |c| c.id == id }
    end

    # Retorna os liderados baseados na função do apoiador
    def liderados
      case funcao_id
      when Funcao::CANDIDATO_ID, Funcao::COORDENADOR_GERAL_ID
        Apoiador.where.not(id: id)
      when Funcao::COORDENADOR_MUNICIPAL_ID
        municipio_id ? Apoiador.where(municipio_id: municipio_id).where.not(id: id) : Apoiador.none
      when Funcao::COORDENADOR_REGIONAL_ID
        regiao_id ? Apoiador.where(regiao_id: regiao_id).where.not(id: id) : Apoiador.none
      when Funcao::COORDENADOR_BAIRRO_ID
        bairro_id ? Apoiador.where(bairro_id: bairro_id).where.not(id: id) : Apoiador.none
      else
        # Para Líder e Apoiador, busca recursivamente
        todos_subordinados(incluir_indiretos: true)
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
