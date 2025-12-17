module Mobile
  class SessionsController < ApplicationController
    skip_before_action :authenticate_apoiador!

    # GET /m/:codigo  (magic link)
    def create
      codigo = params[:codigo]
      apoiador = Apoiador.find_by(verification_code: codigo)

      if apoiador && apoiador.codigo_valido?(codigo)
        apoiador.limpar_codigo_acesso!
        session[:apoiador_id] = apoiador.id
        session.delete(:auth_apoiador_id)
        Gamification::PointsService.award_points(apoiador: apoiador, action_type: "daily_login")

        redirect_to root_path, notice: "Bem-vindo, #{apoiador.name}!"
      else
        redirect_to login_path, alert: "Link inválido ou expirado."
      end
    end
  end
end
