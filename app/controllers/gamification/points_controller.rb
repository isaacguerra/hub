module Gamification
  class PointsController < BaseController
    def index
      @points = Gamification::Point.includes(:apoiador).order(points: :desc).page(params[:page])
    end

    def adjust
      apoiador = Apoiador.find(params[:apoiador_id])
      points_to_add = params[:points].to_i
      reason = params[:reason]

      if points_to_add != 0
        Gamification::PointsService.award_points(
          apoiador: apoiador,
          action_type: "manual_adjustment",
          metadata: { reason: reason, admin_id: current_apoiador.id }
        )
        # Nota: O serviço espera action_type mapeado em GAMIFICATION_WEIGHTS para calcular pontos.
        # Como é ajuste manual, precisamos adaptar o serviço ou criar um log manual.
        # Ajuste rápido: criar log manual e atualizar saldo.
        
        ActiveRecord::Base.transaction do
          Gamification::ActionLog.create!(
            apoiador: apoiador,
            action_type: "manual_adjustment",
            points_awarded: points_to_add,
            metadata: { reason: reason, admin_id: current_apoiador.id }
          )
          
          point_record = Gamification::Point.find_or_create_by!(apoiador: apoiador)
          point_record.points += points_to_add
          point_record.level = Gamification::PointsService.calculate_level(point_record.points)
          point_record.save!
        end

        redirect_to gamification_points_path, notice: "Pontos ajustados com sucesso."
      else
        redirect_to gamification_points_path, alert: "Valor de pontos inválido."
      end
    rescue StandardError => e
      redirect_to gamification_points_path, alert: "Erro ao ajustar pontos: #{e.message}"
    end
  end
end
