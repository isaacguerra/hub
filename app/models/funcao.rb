# == Schema Information
# Uma Função representa o papel ou cargo que um Apoiador desempenha dentro da organização
# que pode ser Candidato, Coordenador Geral, Coordenador de Município, Coordenador de Região, Coordenador de Bairro, Lider e Apoiador(que é a funcao inicial de um Apoiador).

class Funcao < ApplicationRecord
  has_many :apoiadores

  alias_attribute :nome, :name

  validates :name, presence: true

  # IDs fixos conforme regra de negócio
  CANDIDATO_ID = 1
  COORDENADOR_GERAL_ID = 2
  COORDENADOR_REGIONAL_ID = 3
  COORDENADOR_MUNICIPAL_ID = 4
  COORDENADOR_BAIRRO_ID = 5
  LIDER_ID = 6
  APOIADOR_ID = 7
end
