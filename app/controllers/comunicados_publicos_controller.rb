class ComunicadosPublicosController < ApplicationController
  skip_before_action :authenticate_apoiador!
  layout "auth"

  def ler
    @comunicado_apoiador = ComunicadoApoiador.find_by(
      comunicado_id: params[:comunicado_id],
      apoiador_id: params[:apoiador_id]
    )

    if @comunicado_apoiador
      @comunicado_apoiador.update(recebido: true, engajado: true)
      @comunicado = @comunicado_apoiador.comunicado
    else
      redirect_to login_path, alert: "Link inválido ou expirado."
    end
  end
end
