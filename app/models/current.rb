class Current < ActiveSupport::CurrentAttributes
  attribute :apoiador
  attribute :avatar
  attribute :user_agent, :ip_address

  resets { Time.zone = nil }

  def apoiador=(apoiador)
    super
    self.avatar = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp) if apoiador
    # Time.zone = apoiador.time_zone if apoiador.respond_to?(:time_zone)
  end
end
