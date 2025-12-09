module Gamification
  class BadgeWorker < ApplicationJob
    queue_as :default

    def perform(apoiador_id)
      apoiador = Apoiador.find_by(id: apoiador_id)
      return unless apoiador

      new_badges = Gamification::BadgeService.check_and_award_badges(apoiador)

      if new_badges.any?
        # Aqui integraremos com a Mensageria para avisar via WhatsApp
        new_badges.each do |badge|
          notify_badge_awarded(apoiador, badge)
        end
      end
    end

    private

    def notify_badge_awarded(apoiador, badge)
      # TODO: Implementar envio via Mensageria::Notificacoes
      # Exemplo:
      # Mensageria::Notificacoes::Gamification.badge_conquistada(apoiador, badge)
      Rails.logger.info "BADGE CONQUISTADA: #{apoiador.name} ganhou #{badge.name}"
    end
  end
end
