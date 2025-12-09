module Mobile
  module Gamification
    class StrategiesController < BaseController
      def edit
        # Busca o registro de vitória mais recente do usuário atual
        @weekly_winner = ::Gamification::WeeklyWinner.where(apoiador: Current.apoiador).order(week_end_date: :desc).first

        unless @weekly_winner
          redirect_to mobile_dashboard_path, alert: "Você não possui vitórias pendentes de estratégia."
        end
      end

      def update
        @weekly_winner = ::Gamification::WeeklyWinner.where(apoiador: Current.apoiador).find(params[:id])

        if @weekly_winner.update(strategy_params)
          redirect_to mobile_dashboard_path, notice: "Estratégia salva com sucesso! Obrigado por compartilhar."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def strategy_params
        params.require(:gamification_weekly_winner).permit(:winning_strategy)
      end
    end
  end
end
