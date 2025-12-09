module Gamification
  class RankingService
    # Retorna array de hashes: [{ apoiador: Apoiador, points: 150 }, ...]
    def self.top_apoiadores(period: :daily, limit: 10, date: Time.current)
      range = time_range_for(period, date)
      
      # Agrupa logs por apoiador e soma pontos
      ranking_data = Gamification::ActionLog
        .where(created_at: range)
        .group(:apoiador_id)
        .order('SUM(points_awarded) DESC')
        .limit(limit)
        .sum(:points_awarded)

      # Carrega os objetos Apoiador para retornar estrutura completa
      apoiadores = Apoiador.where(id: ranking_data.keys).index_by(&:id)

      ranking_data.map do |apoiador_id, points|
        {
          apoiador: apoiadores[apoiador_id],
          points: points,
          period: period
        }
      end
    end

    def self.winner(period: :daily, date: Time.current)
      top_apoiadores(period: period, limit: 1, date: date).first
    end

    private

    def self.time_range_for(period, date)
      case period.to_sym
      when :daily
        date.beginning_of_day..date.end_of_day
      when :weekly
        date.beginning_of_week..date.end_of_week
      when :monthly
        date.beginning_of_month..date.end_of_month
      else
        date.beginning_of_day..date.end_of_day
      end
    end
  end
end
