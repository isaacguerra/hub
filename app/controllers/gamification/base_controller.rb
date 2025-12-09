module Gamification
  class BaseController < ApplicationController
    before_action :authenticate_apoiador!
    before_action :authorize_admin!
    layout "application"

    private

    def authorize_admin!
      unless current_apoiador.candidato? || current_apoiador.coordenador_geral?
        redirect_to root_path, alert: "Acesso não autorizado. Apenas administradores podem acessar esta área."
      end
    end
  end
end
