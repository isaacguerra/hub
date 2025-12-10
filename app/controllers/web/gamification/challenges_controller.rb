module Web
  module Gamification
  class ChallengesController < BaseController
    before_action :set_challenge, only: %i[edit update destroy]

    def index
      @challenges = ::Gamification::Challenge.order(starts_at: :desc)
    end

    def new
      @challenge = ::Gamification::Challenge.new
    end

    def create
      @challenge = ::Gamification::Challenge.new(challenge_params)

      if @challenge.save
        redirect_to gamification_challenges_path, notice: "Missão criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @challenge.update(challenge_params)
        redirect_to gamification_challenges_path, notice: "Missão atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @challenge.destroy
      redirect_to gamification_challenges_path, notice: "Missão removida com sucesso."
    end

    private

    def set_challenge
      @challenge = ::Gamification::Challenge.find(params[:id])
    end

    def challenge_params
      # Permitimos que rules seja um hash de qualquer estrutura
      permitted = params.require(:gamification_challenge).permit(:title, :description, :reward, :starts_at, :ends_at, rules: {})
      
      # Tratamento dos dados antes de salvar:
      if permitted[:rules].present?
        # 1. Remove valores vazios ou zero
        # 2. Converte os valores de String para Integer
        permitted[:rules] = permitted[:rules].to_h.select { |_, v| v.present? && v.to_i > 0 }
                                            .transform_values(&:to_i)
      end

      permitted
    end
  end
end
end
