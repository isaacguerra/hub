# == Schema Information
# Um Município representa uma divisão administrativa dentro de um estado, 
# um municipio tem muitas regiões e muitos apoiadores associados a ele.

class Municipio < ApplicationRecord
  has_many :regioes, dependent: :destroy
  has_many :apoiadores

  alias_attribute :nome, :name

  validates :name, presence: true
end
