# funcao que busca a rede do apoiador
# recebe i id do apoaidor e retorna a rede
# Coordenadores do apoiador:
# um array com os coordenadores que sao, os Candidatos, os Coordenadores Gerais,
# os coordenadores de municipio, os coordenadores de regiao e os coodernadores de bairro
# deve-se excluir duplicidades
# Liderados do apoiador:
# caso a funcao do apoiador seja Candidato ou coordenador geral retorne todos os apoiadores cadastrados
# caso a funcao do apoiador seja coordenador de municipio retorne todos os apoiadores do municipio
# caso a funcao do apoiador seja coordenador de regiao retorne todos os apoiadores da regiao
# caso a funcao do apoiador seja coordenador de bairro retorne todos os apoiadores do bairro
# caso a funcao do apoiador se lider retorne todos os apoiadores que tem esse apoiador como lider
# e os liderados desses liderados recursivamente
# deve-se excluir duplicidades
# Lider do apoiador:
# retrona tambem é Lider direto do apoiador
# retorna um hash com as chaves :coordenadores, :lider e :liderados
# onde os coordenadores é um array de apoiadores que sao coordenadores do apoiador
# o lider é o apoiador que é lider direto do apoiador
# e os liderados é um array de apoiadores que sao liderados diretos e indiretos do apoiador
# os campos retornados dos apoiadores devem ser: id, name, whatsapp, funcao.name, municipio.name, regiao.name, bairro.name
module Utils
  class RedeApoiador
    FUNCOES_COORDENADORAS = [
      "Candidato",
      "Coordenador Geral",
      "Coordenador de Município",
      "Coordenador de Região",
      "Coordenador de Bairro"
    ].freeze

    def self.busca_rede(apoiador_id)
      apoiador = Apoiador.includes(:funcao, :municipio, :regiao, :bairro, :lider, lider: [ :funcao, :municipio, :regiao, :bairro ]).find_by(id: apoiador_id)
      return nil unless apoiador

      {
        coordenadores: apoiador.coordenadores.map { |c| serialize_apoiador(c) },
        lider: apoiador.lider ? serialize_apoiador(apoiador.lider) : nil,
        liderados: apoiador.liderados.map { |l| serialize_apoiador(l) }
      }
    end

    private

    def self.serialize_apoiador(apoiador)
      {
        id: apoiador.id,
        name: apoiador.name,
        whatsapp: apoiador.whatsapp,
        funcao: apoiador.funcao&.name,
        municipio: apoiador.municipio&.name,
        regiao: apoiador.regiao&.name,
        bairro: apoiador.bairro&.name
      }
    end
  end
end
