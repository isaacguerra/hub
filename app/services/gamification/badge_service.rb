module Gamification
  class BadgeService
    def self.check_and_award_badges(apoiador)
      # Carrega todas as badges que o apoiador AINDA NÃO tem
      badges_owned_ids = apoiador.gamification_badges.pluck(:id)
      potential_badges = Gamification::Badge.where.not(id: badges_owned_ids)

      new_badges = []

      potential_badges.each do |badge|
        if criteria_met?(apoiador, badge.criteria)
          Gamification::ApoiadorBadge.create!(
            apoiador: apoiador,
            badge: badge,
            awarded_at: Time.current
          )
          new_badges << badge
        end
      end

      # Retorna as novas badges para notificação
      new_badges
    end

    def self.criteria_met?(apoiador, criteria)
      return false if criteria.blank?

      # Exemplo de critério: { "action_type" => "convite_accepted", "count" => 5 }
      action_type = criteria["action_type"]
      required_count = criteria["count"].to_i

      return false unless action_type && required_count > 0

      # Conta quantas vezes essa ação ocorreu para este apoiador
      # Otimização: Poderíamos ter contadores cacheados no futuro
      actual_count = Gamification::ActionLog.where(
        apoiador: apoiador, 
        action_type: action_type
      ).count

      actual_count >= required_count
    end
  end
end
