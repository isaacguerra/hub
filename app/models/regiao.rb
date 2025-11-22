# == Schema Information
# Uma Região representa uma subdivisão administrativa dentro de um município,
# podendo ter vários bairros e apoiadores associados a ela.

class Regiao < ApplicationRecord
  belongs_to :municipio
  belongs_to :coordenador, class_name: 'Apoiador', optional: true

  alias_attribute :nome, :name

  has_many :bairros, dependent: :destroy
  has_many :apoiadores
  has_many :comunicados

  validates :name, presence: true
  validates :municipio, presence: true
end
