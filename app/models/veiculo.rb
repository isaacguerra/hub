# == Schema Information
# Um Veículo representa um meio de transporte associado a um Apoiador,
# utilizado para deslocamentos em atividades relacionadas ao sistema.

class Veiculo < ApplicationRecord
  belongs_to :apoiador

  validates :modelo, :placa, :tipo, presence: true
  validates :apoiador, presence: true
  validates :disponivel, inclusion: { in: [true, false] }
end
