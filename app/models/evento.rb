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

  # Associações de Filtro (Opcionais)
  belongs_to :filtro_funcao, class_name: "Funcao", optional: true
  belongs_to :filtro_municipio, class_name: "Municipio", optional: true
  belongs_to :filtro_regiao, class_name: "Regiao", optional: true
  belongs_to :filtro_bairro, class_name: "Bairro", optional: true

  has_many :apoiadores_eventos, dependent: :destroy
  has_many :apoiadores, through: :apoiadores_eventos

  validates :titulo, :data, presence: true
  validates :coordenador, presence: true
  validate :coordenador_pode_criar_evento

  # Callbacks
  after_create :notificar_novo_evento
  after_update :notificar_atualizacao_evento, if: :saved_changes?

  # Retorna APENAS os liderados que atendem aos critérios de filtro
  def destinatarios_filtrados
    scope = Apoiador.all

    # Aplica filtros se existirem
    scope = scope.where(funcao_id: filtro_funcao_id) if filtro_funcao_id.present?
    scope = scope.where(municipio_id: filtro_municipio_id) if filtro_municipio_id.present?
    scope = scope.where(regiao_id: filtro_regiao_id) if filtro_regiao_id.present?
    scope = scope.where(bairro_id: filtro_bairro_id) if filtro_bairro_id.present?

    scope
  end

  def descricao_publico_alvo
    filtros = []
    filtros << "Função: #{filtro_funcao.nome}" if filtro_funcao
    filtros << "Município: #{filtro_municipio.nome}" if filtro_municipio
    filtros << "Região: #{filtro_regiao.nome}" if filtro_regiao
    filtros << "Bairro: #{filtro_bairro.nome}" if filtro_bairro

    if filtros.any?
      filtros.join(" | ")
    else
      "Todos (Rede completa)"
    end
  end

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
