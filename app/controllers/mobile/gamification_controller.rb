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
  end
end
