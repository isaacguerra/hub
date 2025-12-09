module Mobile
  class DashboardController < BaseController
    def index
      # Campeões Temporais (Dia, Semana, Mês)
      @daily_winner = Gamification::RankingService.winner(period: :daily)
      @weekly_winner = Gamification::RankingService.winner(period: :weekly)
      @monthly_winner = Gamification::RankingService.winner(period: :monthly)

      # Hall da Fama (Top 3 Geral - Ouro)
      @gold_champions = Gamification::Point.includes(:apoiador)
                                           .order(points: :desc)
                                           .limit(3)
    end
  end
end
