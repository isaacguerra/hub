module Gamification
  class NotifyChallengeJob < ApplicationJob
    queue_as :default

    def perform(challenge_id, action_type)
      challenge = Gamification::Challenge.find_by(id: challenge_id)
      return unless challenge

      # Define a mensagem baseada na ação
      prefixo = action_type.to_s == "created" ? "🚀 Nova Missão Disponível!" : "📝 Missão Atualizada!"
      
      # Link para a missão (ajuste conforme suas rotas mobile/web)
      # Assumindo que existe uma rota mobile para ver detalhes da missão
      # link = Rails.application.routes.url_helpers.mobile_gamification_challenge_url(challenge, host: ENV.fetch("BASE_URL", "app.ivonechagas.com.br"))
      # Como a rota ainda não existe, vou usar um link genérico para o dashboard
      link = "#{ENV.fetch('BASE_URL', 'https://app.ivonechagas.com.br')}/mobile/gamification/challenges/#{challenge.id}"

      mensagem = <<~MSG
        #{prefixo}
        
        *#{challenge.title}*
        
        #{challenge.description}
        
        📅 Até: #{challenge.ends_at.strftime('%d/%m/%Y')}
        
        Participe agora e ganhe pontos!
        Acesse: #{link}
      MSG

      # Itera sobre todos os apoiadores com WhatsApp válido
      # Em produção com muitos usuários, idealmente usar find_each ou dividir em lotes
      Apoiador.where.not(whatsapp: nil).find_each do |apoiador|
        next if apoiador.whatsapp.blank?

        SendWhatsappJob.perform_later(
          whatsapp: apoiador.whatsapp,
          mensagem: mensagem
        )
      end
    end
  end
end
