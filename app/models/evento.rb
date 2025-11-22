# == Schema Information
# Um Evento representa uma atividade ou reunião organizada por um Coordenador (Apoiador)
# para a participação de vários Apoiadores.
# um Evento pode ser criado por Coordenador Geral, Coordenador de Município, Coordenador de Região ou Coordenador de Bairro ou Lider.
# Ao criar um Evento, o Coordenador responsável deve ser associado ao Evento.
# Mensageria
# Ao criar um Evento, devemos gravar uma mensagem no channel mensageria no redis com os dados do novo Evento.
# Caso o Evento seja atualizado ou cancelado, devemos gravar uma mensagem no channel mensageria no redis com os dados atualizados do Evento.

class Evento < ApplicationRecord
  belongs_to :coordenador, class_name: 'Apoiador'

  has_many :apoiadores_eventos, dependent: :destroy
  has_many :apoiadores, through: :apoiadores_eventos

  validates :titulo, :data, presence: true
  validates :coordenador, presence: true
  validate :coordenador_pode_criar_evento

  # Callbacks
  after_create :notificar_novo_evento
  after_update :notificar_atualizacao_evento, if: :saved_changes?

  private

  def coordenador_pode_criar_evento
    return if coordenador.blank?

    unless coordenador.pode_coordenar? || coordenador.lider?
      errors.add(:coordenador, 'deve ser Coordenador ou Líder para criar eventos')
    end
  end

  def notificar_novo_evento
    Mensageria::Notificacoes::Eventos.notificar_novo_evento(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar novo evento #{id}: #{e.message}"
  end

  def notificar_atualizacao_evento
    Mensageria::Notificacoes::Eventos.notificar_atualizacao_evento(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar atualização do evento #{id}: #{e.message}"
  end
end
