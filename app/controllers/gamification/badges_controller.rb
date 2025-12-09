module Gamification
  class BadgesController < BaseController
    before_action :set_badge, only: %i[edit update]

    def index
      @badges = Gamification::Badge.order(:name)
    end

    def edit
    end

    def update
      if @badge.update(badge_params)
        redirect_to gamification_badges_path, notice: "Medalha atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_badge
      @badge = Gamification::Badge.find(params[:id])
    end

    def badge_params
      params.require(:gamification_badge).permit(:name, :description, :image_url, :criteria)
    end
  end
end
