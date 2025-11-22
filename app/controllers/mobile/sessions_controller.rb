module Mobile
  class SessionsController < ApplicationController
    skip_before_action :authenticate_apoiador!, only: [ :create ]

    def create
      codigo = params[:codigo]
      apoiador = Apoiador.find_by(verification_code: codigo)

      if apoiador && apoiador.codigo_valido?(codigo)
        session[:apoiador_id] = apoiador.id
        apoiador.limpar_codigo_acesso!

        redirect_to mobile_dashboard_path, notice: "Bem-vindo, #{apoiador.nome}!"
      else
        redirect_to login_path, alert: "Link inválido ou expirado."
      end
    end

    def destroy
      session[:apoiador_id] = nil
      redirect_to login_path, notice: "Saiu com sucesso."
    end
  end
end
