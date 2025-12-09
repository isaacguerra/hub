module Gamification
  class ChallengesController < BaseController
    before_action :set_challenge, only: %i[edit update destroy]

    def index
      @challenges = Gamification::Challenge.order(starts_at: :desc)
    end

    def new
      @challenge = Gamification::Challenge.new
    end

    def create
      @challenge = Gamification::Challenge.new(challenge_params)

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
      @challenge = Gamification::Challenge.find(params[:id])
    end

    def challenge_params
      # Rules deve ser passado como JSON string ou hash, dependendo do form
      params.require(:gamification_challenge).permit(:title, :description, :reward, :starts_at, :ends_at, :rules)
    end
  end
end
