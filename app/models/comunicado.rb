# == Schema Information
# Um Comunicado representa uma mensagem enviada por um Líder para os Apoiadores
# Se o Apoiador tiver a função Coordenador Geral, Coordenador de Município, Coordenador de Região ou Coordenador de Bairro ou líder
# ao criar um Comunicado, devemos gravar uma mensagem no channel mensageria no redis com os dados do novo Comunicado.
# Ao criar um comunicado os Líderes do Apoiador devem receber uma notificação no redis que o comunicado foi criado e para qual grupo foi enviado

class Comunicado < ApplicationRecord
  belongs_to :lider, class_name: "Apoiador"

  has_many :comunicado_apoiadores, dependent: :destroy
  has_many :apoiadores, through: :comunicado_apoiadores

  validates :titulo, :mensagem, :data, presence: true
  validates :lider, presence: true
  validate :lider_pode_criar_comunicado

  # Callbacks
  after_create :notificar_novo_comunicado

  private

  def lider_pode_criar_comunicado
    return if lider.blank?

    unless lider.pode_coordenar? || lider.lider?
      errors.add(:lider, "deve ser Coordenador ou Líder para criar comunicados")
    end
  end

  def notificar_novo_comunicado
    Mensageria::Notificacoes::Comunicados.notificar_novo_comunicado(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar novo comunicado #{id}: #{e.message}"
  end
end
