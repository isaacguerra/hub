module Mobile
  class GamificationController < BaseController
    def index
      @challenges = ::Gamification::Challenge.where("ends_at >= ?", Time.current).order(starts_at: :asc)
      @my_points = ::Gamification::Point.find_by(apoiador: Current.apoiador)
      @my_level = @my_points&.level || 1
      @my_xp = @my_points&.points || 0
    end

    def show
      @challenge = ::Gamification::Challenge.find(params[:id])
      @participants = @challenge.participants.includes(:apoiador).order(points: :desc).limit(50)

      # Meu progresso nesta missão
      @my_participation = @challenge.participants.find_by(apoiador: Current.apoiador)
    end

    def profile
      @apoiador = Apoiador.find(params[:id])
      @points = ::Gamification::Point.find_by(apoiador: @apoiador)
      @level = @points&.level || 1
      @xp = @points&.points || 0
      
      @badges = ::Gamification::ApoiadorBadge.where(apoiador: @apoiador).includes(:badge)
      @challenges_won = ::Gamification::Challenge.where(winner: @apoiador)
      @weekly_wins = ::Gamification::WeeklyWinner.where(apoiador: @apoiador).order(week_end_date: :desc)
    end

    def participate
      @challenge = ::Gamification::Challenge.find(params[:id])
      
      # Verifica se já participa para evitar duplicidade
      participant = @challenge.participants.find_or_initialize_by(apoiador: Current.apoiador)
      
      if participant.new_record?
        participant.save!
        # Dispara notificação para toda a base
        ::Gamification::NotifyParticipationJob.perform_later(participant.id)
        redirect_to mobile_gamification_path(@challenge), notice: "Você agora está participando desta missão!"
      else
        redirect_to mobile_gamification_path(@challenge), alert: "Você já está participando."
      end
    end
  end
end
