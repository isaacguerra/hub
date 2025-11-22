# == Schema Information
# Um Convite representa um convite enviado por um apoiador para um possível novo apoiador.
# Contém informações sobre o nome do convidado, seu contato via WhatsApp e o status do convite.
# um convite pode ser "pendente", "aceito" ou "recusado".
# ao aceitar o convite o convidado deve informar os dados necessários para criar um Apoiador
# os dados do convite como nome e whatsapp podem ser usados para preencher automaticamente o cadastro do novo apoiador e nao podem ser mudados quando o convite for aceito.
# apos o convite ser aceito, o status deve ser atualizado para "aceito" e o novo apoiador deve ser criado no sistema.
# usando o channel mensageria gravaremos uma mensagem de convite aceito no redis para notificar outros sistemas.
# alem de convite aceito podemos ter o convite recusado, nesse caso o status deve ser atualizado para "recusado" e devemos gravar uma mensagem de convite recusado no redis.

class Convite < ApplicationRecord
  belongs_to :enviado_por, class_name: 'Apoiador'

  validates :nome, :whatsapp, :status, presence: true
  validates :enviado_por, presence: true
  validates :status, inclusion: { in: %w[pendente aceito recusado] }

  # Callbacks
  before_validation :normalizar_whatsapp
  after_create :notificar_novo_convite
  after_update :notificar_mudanca_status, if: :saved_change_to_status?

  private

  def normalizar_whatsapp
    self.whatsapp = Utils::NormalizaNumeroWhatsapp.format(whatsapp)
  end

  def notificar_novo_convite
    Mensageria::Notificacoes::Convites.notificar_novo_convite(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar novo convite #{id}: #{e.message}"
  end

  def notificar_mudanca_status
    case status
    when 'aceito'
      # Nota: a notificação de convite aceito é disparada ao criar o apoiador
      # não aqui, pois precisamos do objeto Apoiador completo
    when 'recusado'
      Mensageria::Notificacoes::Convites.notificar_convite_recusado(self)
    end
  end
end
