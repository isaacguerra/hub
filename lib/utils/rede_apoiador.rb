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

      coordenadores = busca_coordenadores(apoiador)
      lider = apoiador.lider ? serialize_apoiador(apoiador.lider) : nil
      liderados = busca_liderados(apoiador)

      {
        coordenadores: coordenadores,
        lider: lider,
        liderados: liderados
      }
    end

    private

    def self.busca_coordenadores(apoiador)
      # Busca coordenadores globais
      globais = Apoiador.joins(:funcao).where(funcoes: { name: ["Candidato", "Coordenador Geral"] })
      
      # Busca coordenadores por localidade
      municipais = apoiador.municipio_id ? Apoiador.joins(:funcao).where(funcoes: { name: "Coordenador de Município" }, municipio_id: apoiador.municipio_id) : []
      regionais = apoiador.regiao_id ? Apoiador.joins(:funcao).where(funcoes: { name: "Coordenador de Região" }, regiao_id: apoiador.regiao_id) : []
      bairros = apoiador.bairro_id ? Apoiador.joins(:funcao).where(funcoes: { name: "Coordenador de Bairro" }, bairro_id: apoiador.bairro_id) : []

      # Une, remove duplicidades e o próprio apoiador
      todos = (globais + municipais + regionais + bairros).uniq
      todos.reject! { |c| c.id == apoiador.id }
      
      todos.map { |c| serialize_apoiador(c) }
    end

    def self.busca_liderados(apoiador)
      funcao_nome = apoiador.funcao&.name
      
      scope = case funcao_nome
              when "Candidato", "Coordenador Geral"
                Apoiador.all
              when "Coordenador de Município"
                apoiador.municipio_id ? Apoiador.where(municipio_id: apoiador.municipio_id) : Apoiador.none
              when "Coordenador de Região"
                apoiador.regiao_id ? Apoiador.where(regiao_id: apoiador.regiao_id) : Apoiador.none
              when "Coordenador de Bairro"
                apoiador.bairro_id ? Apoiador.where(bairro_id: apoiador.bairro_id) : Apoiador.none
              else
                return busca_liderados_recursivo(apoiador)
              end

      scope.where.not(id: apoiador.id)
           .includes(:funcao, :municipio, :regiao, :bairro)
           .map { |l| serialize_apoiador(l) }
    end

    def self.busca_liderados_recursivo(apoiador, acumulado = Set.new, resultado = [])
      apoiador.subordinados.includes(:funcao, :municipio, :regiao, :bairro).each do |liderado|
        next if acumulado.include?(liderado.id)
        
        resultado << serialize_apoiador(liderado)
        acumulado.add(liderado.id)
        
        busca_liderados_recursivo(liderado, acumulado, resultado)
      end
      resultado
    end

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
