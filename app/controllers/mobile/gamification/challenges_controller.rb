module Mobile
  module Gamification
    class ChallengesController < Mobile::BaseController
      before_action :authorize_admin!
      before_action :set_challenge, only: %i[show edit update destroy]

      def index
        @challenges = ::Gamification::Challenge.order(starts_at: :desc)
      end

      def show
      end

      def new
        @challenge = ::Gamification::Challenge.new
      end

      def create
        @challenge = ::Gamification::Challenge.new(challenge_params)

        if @challenge.save
          redirect_to mobile_gamification_challenges_path, notice: "Missão criada com sucesso."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @challenge.update(challenge_params)
          redirect_to mobile_gamification_challenges_path, notice: "Missão atualizada com sucesso."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @challenge.destroy
        redirect_to mobile_gamification_challenges_path, notice: "Missão removida com sucesso."
      end

      private

      def set_challenge
        @challenge = ::Gamification::Challenge.find(params[:id])
      end

      def authorize_admin!
        unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
          redirect_to mobile_gamification_index_path, alert: "Acesso restrito a administradores."
        end
      end

      def challenge_params
        permitted = params.require(:gamification_challenge).permit(:title, :description, :reward, :starts_at, :ends_at, rules: {})
        
        # Limpa regras vazias ou zeradas
        if permitted[:rules].present?
          permitted[:rules] = permitted[:rules].select { |_, v| v.present? && v.to_i > 0 }
        end

        permitted
      end
    end
  end
end
