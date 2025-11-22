# == Schema Information
# Um Bairro representa uma subdivisão administrativa dentro de uma região,
# podendo ter vários apoiadores associados a ele.

class Bairro < ApplicationRecord
  belongs_to :regiao
  has_many :apoiadores

  alias_attribute :nome, :name

  validates :name, presence: true
  validates :regiao, presence: true
end
