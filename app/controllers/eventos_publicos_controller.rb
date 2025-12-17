class EventosPublicosController < ApplicationController
  skip_before_action :authenticate_apoiador!
  layout "auth"

  def participar
    @evento = Evento.find(params[:evento_id])
    @apoiador = Apoiador.find(params[:apoiador_id])

    # Verifica se já participa
    @participacao = ApoiadoresEvento.find_or_initialize_by(
      evento: @evento,
      apoiador: @apoiador
    )

    if @participacao.new_record?
      @participacao.assigned_at = Time.current
      @participacao.assigned_by = "link_publico"

      if @participacao.save
        # Sucesso (notificações disparadas pelo callback do model)
      else
        redirect_to login_path, alert: "Não foi possível confirmar sua presença."
        nil
      end
    end

    # Se já existia ou acabou de salvar, renderiza sucesso
  rescue ActiveRecord::RecordNotFound
    redirect_to login_path, alert: "Evento ou Apoiador não encontrado."
  end
end
