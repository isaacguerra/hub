module Gamification
  class CloseWeeklyCycleJob < ApplicationJob
    queue_as :default

    def perform
      # 1. Identificar a semana que passou
      last_week_start = 1.week.ago.beginning_of_week.to_date
      last_week_end = 1.week.ago.end_of_week.to_date

      # 2. Encontrar o vencedor da semana passada
      winner_data = Gamification::RankingService.top_apoiadores(period: :weekly, limit: 1, date: 1.week.ago).first

      return unless winner_data # Ninguém pontuou na semana passada

      apoiador = winner_data[:apoiador]
      points = winner_data[:points]

      # 3. Criar registro histórico
      Gamification::WeeklyWinner.create!(
        apoiador: apoiador,
        week_start_date: last_week_start,
        week_end_date: last_week_end,
        points_total: points
      )

      # 4. Enviar notificação solicitando a estratégia
      link = Rails.application.routes.url_helpers.edit_mobile_gamification_strategy_url(protocol: 'https')
      message = I18n.t('mensagens.gamification.vencedor_semanal', 
        nome: apoiador.name, 
        pontos: points, 
        link: link
      )

      SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: message)
    end
  end
end
