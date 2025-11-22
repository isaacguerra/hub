# == Schema Information
# Uma Função representa o papel ou cargo que um Apoiador desempenha dentro da organização
# que pode ser Candidato, Coordenador Geral, Coordenador de Município, Coordenador de Região, Coordenador de Bairro, Lider e Apoiador(que é a funcao inicial de um Apoiador).

class Funcao < ApplicationRecord
  has_many :apoiadores

  alias_attribute :nome, :name

  validates :name, presence: true
end
