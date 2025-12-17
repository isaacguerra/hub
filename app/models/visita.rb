
# == Schema Information
# Uma Visita representa uma interação entre um Líder e um Apoiador,
# onde o Líder realiza uma visita ao Apoiador para acompanhamento e suporte.
# Cada Visita contém um relato da interação e o status da visita.
# Um lider pode solicitar a visita a um apoiador.
# a visita sode ser marcada como pendente, concluída ou cancelada.
# Caso o Apoiador tenha a função de Coordenador Geral, Coordenador de Município, Coordenador de Região ou Coordenador de Bairro, o Líder deve registrar a visita no sistema.
# Os Candidatos, e Coordenadore Gerais podem ver, criar e atualizar visitas para todos os apoiadores registrados no sistema.
# O Coordenador de Município pode ver, criar e atualizar visitas para os apoiadores do seu município.
# O Coordenador de Região pode ver, criar e atualizar visitas para os apoiadores da sua região.
# O Coordenador de Bairro pode ver, criar e atualizar visitas para os apoiadores do seu bairro.
# O Líder pode ver, criar e atualizar visitas apenas para os apoiadores que ele lidera.
# apos a visita ser criada, devemos gravar uma mensagem no channel mensageria no redis com os dados da nova Visita.
# devemos registrar uma notificação para o Apoiador informando sobre a nova visita agendada.
# devemos resgistrar uma notificação para o Líder informando sobre a conclusão ou cancelamento da visita.
# devemos registrar uma notificacao para o Coordenador Geral, Coordenador de Município a quem o apoiador pertence, Coordenador de Região a que o apoiador visitado pertence e Coordenador de Bairro que o apoiador Pertence, quando uma visita for concluída ou cancelada tbm.
# apos a visita feita o lider podera atualizar o status da visita para concluída ou cancelada e adicionar um relato da visita.
# apos a visita ser concluída ou cancelada, devemos gravar uma mensagem no channel mensageria no redis com os dados da Visita atualizada.
# e devemos notificar o Apoiador sobre a conclusão ou cancelamento da visita.
# e devemos notificar o Coordenador Geral, Coordenador de Município a quem o apoiador pertence, Coordenador de Região a que o apoiador visitado pertence e Coordenador de Bairro que o apoiador Pertence, sobre a conclusão ou cancelamento da visita.
# o relato da visita deve conter informações relevantes sobre a interação entre o Líder e o Apoiador, incluindo pontos discutidos, ações acordadas e feedback do Apoiador.
# os lideres deve receber um notificao com o relato da visita apos o lider registrar o relato da visita.


class Visita < ApplicationRecord
  acts_as_tenant :projeto
  belongs_to :lider, class_name: "Apoiador"
  belongs_to :apoiador

  validates :status, presence: true
  validates :relato, presence: true, if: -> { status == "concluida" }
  validates :lider, :apoiador, presence: true
  validates :status, inclusion: { in: %w[pendente concluida cancelada] }

  # Callbacks
  after_create :notificar_nova_visita
  after_create :pontuar_criacao
  after_update :notificar_atualizacao_visita, if: :saved_change_to_status?

  private

  def pontuar_criacao
    Gamification::PointsService.award_points(
      apoiador: lider,
      action_type: "visit_created",
      resource: self
    )
  rescue StandardError => e
    Rails.logger.error "Erro ao pontuar criação de visita #{id}: #{e.message}"
  end

  def notificar_nova_visita
    Mensageria::Notificacoes::Visitas.notificar_nova_visita(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar nova visita #{id}: #{e.message}"
  end

  def notificar_atualizacao_visita
    return unless status.in?(%w[concluida cancelada])

    if status == "concluida"
      Mensageria::Notificacoes::Visitas.notificar_visita_realizada(self)
    else
      Mensageria::Notificacoes::Visitas.notificar_visita_cancelada(self)
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar atualização da visita #{id}: #{e.message}"
  end
end
