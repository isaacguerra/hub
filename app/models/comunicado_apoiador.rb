# == Schema Information
# Um ComunicadoApoiador representa a relação entre um Comunicado e um Apoiador
# o Apoiador apos receber o Comunicado pode marcar como recebido e engajado.

class ComunicadoApoiador < ApplicationRecord
  belongs_to :comunicado
  belongs_to :apoiador

  validates :comunicado, :apoiador, presence: true
  validates :recebido, :engajado, inclusion: { in: [ true, false ] }

  # Callbacks
  after_create :notificar_apoiador
  after_update :disparar_notificacoes_engajamento, if: -> { saved_change_to_engajado? && engajado? }

  private

  def notificar_apoiador
    Mensageria::Notificacoes::Comunicados.enviar_para_apoiador(comunicado, apoiador)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar apoiador #{apoiador_id} do comunicado #{comunicado_id}: #{e.message}"
  end

  def disparar_notificacoes_engajamento
    Mensageria::Notificacoes::Comunicados.notificar_engajamento(self)
  end
end
