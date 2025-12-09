module Gamification
  class PointsService
    def self.award_points(apoiador:, action_type:, resource: nil, metadata: {})
      points = points_for(action_type)
      return { success: false, reason: :unknown_action } if points.zero?

      # Idempotência: se resource for passado, verifica se já pontuou
      if resource.present? && Gamification::ActionLog.exists?(apoiador: apoiador, action_type: action_type, resource: resource)
        return { success: false, reason: :already_awarded }
      end

      # Para ações diárias (ex: login), verificar se já ocorreu hoje
      if action_type == "daily_login" && Gamification::ActionLog.where(apoiador: apoiador, action_type: action_type).where("created_at >= ?", Time.current.beginning_of_day).exists?
        return { success: false, reason: :daily_limit_reached }
      end

      ActiveRecord::Base.transaction do
        # 1. Registrar Log
        Gamification::ActionLog.create!(
          apoiador: apoiador,
          action_type: action_type,
          resource: resource,
          points_awarded: points,
          metadata: metadata
        )

        # 2. Atualizar Pontos do Apoiador
        gamification_point = Gamification::Point.find_or_create_by!(apoiador: apoiador)
        gamification_point.with_lock do
          gamification_point.points += points
          
          # 3. Verificar Level Up
          old_level = gamification_point.level
          new_level = calculate_level(gamification_point.points)
          
          level_up = new_level > old_level
          gamification_point.level = new_level if level_up
          
          gamification_point.save!

          # Aqui poderíamos disparar um evento ou job de notificação de Level Up
          # if level_up
          #   Gamification::LevelUpJob.perform_later(apoiador.id, new_level)
          # end

          # 4. Verificar Progresso em Missões
          Gamification::ChallengeService.check_progress(apoiador, action_type)

          return { 
            success: true, 
            points_awarded: points, 
            total_points: gamification_point.points, 
            level: new_level, 
            level_up: level_up 
          }
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Gamification Error: #{e.message}")
      { success: false, reason: :database_error, message: e.message }
    end

    def self.points_for(action_type)
      GAMIFICATION_WEIGHTS[action_type.to_s] || 0
    end

    def self.calculate_level(points)
      # Encontra o índice do maior valor no array que é menor ou igual aos pontos
      # GAMIFICATION_LEVELS = [0, 100, 300, ...]
      # Se points = 150, levels.select { |l| l <= 150 }.count
      # 0 e 100 são <= 150. Count = 2. Nível = 2.
      
      level = GAMIFICATION_LEVELS.select { |threshold| threshold <= points }.count
      level = 1 if level < 1
      level
    end
  end
end
