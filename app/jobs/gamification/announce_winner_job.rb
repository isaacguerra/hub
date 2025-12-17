module Gamification
  class AnnounceWinnerJob < ApplicationJob
    queue_as :default

    def perform(challenge_id)
      challenge = Gamification::Challenge.find_by(id: challenge_id)
      return unless challenge && challenge.winner

      winner_name = challenge.winner.name
      mission_title = challenge.title
      reward = challenge.reward

      message = I18n.t('mensagens.gamification.missao_concluida', 
        titulo: mission_title, 
        vencedor: winner_name, 
        premio: reward
      )

      # Envia para todos os apoiadores
      Apoiador.find_each do |apoiador|
        SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: message)
      end
    end
  end
end
