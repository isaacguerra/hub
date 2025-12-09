module Gamification
  class ConfigurationsController < BaseController
    # Acesso restrito a Candidatos e Coordenadores Gerais via BaseController
    
    def index
      @action_weights = Gamification::ActionWeight.order(:action_type)
      @levels = Gamification::Level.order(:level)
    end

    def update_weight
      @weight = Gamification::ActionWeight.find(params[:id])
      if @weight.update(weight_params)
        redirect_to gamification_configurations_path, notice: "Peso atualizado com sucesso."
      else
        redirect_to gamification_configurations_path, alert: "Erro ao atualizar peso."
      end
    end

    def update_level
      @level = Gamification::Level.find(params[:id])
      if @level.update(level_params)
        redirect_to gamification_configurations_path, notice: "Nível atualizado com sucesso."
      else
        redirect_to gamification_configurations_path, alert: "Erro ao atualizar nível."
      end
    end

    private

    def weight_params
      params.require(:gamification_action_weight).permit(:points, :description)
    end

    def level_params
      params.require(:gamification_level).permit(:experience_threshold)
    end
  end
end
