module Mobile
  class PerfilController < BaseController
    layout "mobile_profile"

    # mostre o perfil do apoiador atual com os dados pessoais
    # com detalhes e relacionamentos
    # mostre a rede de apoiadores conectados e lideres
    # convites enviados com status
    # visitas recebidas
    # use um card para cada seção
    def show
      @apoiador = Current.apoiador
      @gamification = ::Gamification::Point.find_or_create_by(apoiador: @apoiador)

      # Calculate Level Progress
      current_level_info = ::Gamification::Level.find_by(level: @gamification.level)
      next_level_info = ::Gamification::Level.find_by(level: @gamification.level + 1)

      @xp_current = @gamification.points
      @xp_next = next_level_info&.experience_threshold || @xp_current # Max level fallback
      @xp_start = current_level_info&.experience_threshold || 0

      # Avoid division by zero
      total_range = @xp_next - @xp_start
      @progress_percent = total_range > 0 ? ((@xp_current - @xp_start) / total_range.to_f * 100).clamp(0, 100) : 100

      # Rede
      @rede = @apoiador.rede_completa

      # Stats & Lists
      @visitas_count = @apoiador.visitas_recebidas.count
      @visitas_recentes = @apoiador.visitas_recebidas.order(data: :desc).limit(3)

      @eventos_count = @apoiador.eventos.count
      @eventos_recentes = @apoiador.eventos.order(data_hora: :desc).limit(3)

      @missoes_count = @apoiador.gamification_challenges.count
      @missoes_recentes = @apoiador.gamification_challenges.limit(3)

      @comunicados_recentes = @apoiador.comunicados.order(created_at: :desc).limit(3)

      @convites_count = @apoiador.convites_enviados.count

      @badges = ::Gamification::ApoiadorBadge.where(apoiador: @apoiador).includes(:badge)
      @challenges_won = ::Gamification::Challenge.where(winner: @apoiador)
      @weekly_wins = ::Gamification::WeeklyWinner.where(apoiador: @apoiador).order(week_end_date: :desc)
    end
  end
end
