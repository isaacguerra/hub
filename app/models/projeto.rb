class Projeto < ApplicationRecord
  has_one_attached :avatar

  has_many :apoiadores
  has_many :eventos
  has_many :convites
  has_many :visitas
  has_many :comunicados
  has_many :veiculos
  has_many :apoiadores_evento
  has_many :comunicado_apoiador

  validates :name, :slug, presence: true
end
