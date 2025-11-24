# == Schema Information
# Um Apoiador quando participar de um evento terá seu registro nesta tabela

class ApoiadoresEvento < ApplicationRecord
  belongs_to :apoiador
  belongs_to :evento

  validates :assigned_at, :assigned_by, presence: true
  validates :apoiador, :evento, presence: true

  # Callbacks
  after_create :notificar_participacao

  private

  def notificar_participacao
    Mensageria::Notificacoes::Eventos.notificar_participacao_confirmada(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar apoiador #{apoiador_id} do evento #{evento_id}: #{e.message}"
  end
end
