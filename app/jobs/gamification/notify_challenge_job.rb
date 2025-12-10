module Gamification
  class NotifyChallengeJob < ApplicationJob
    queue_as :default

    def perform(challenge_id, action_type)
      challenge = Gamification::Challenge.find_by(id: challenge_id)
      return unless challenge

      # Define a mensagem baseada na ação
      prefixo = action_type.to_s == "created" ? "🚀 Nova Missão Disponível!" : "📝 Missão Atualizada!"
      
      # Link para a missão
      link = "#{ENV.fetch('BASE_URL', 'https://app.ivonechagas.com.br')}/mobile/gamification/#{challenge.id}"

      # Traduzir regras para texto humano
      regras_texto = ""
      if challenge.rules.present?
        regras_texto = "\n📋 *O que fazer:*\n"
        challenge.rules.each do |action_type, qtd|
          weight = ::Gamification::ActionWeight.find_by(action_type: action_type)
          descricao = weight&.description || action_type.humanize
          regras_texto += "- #{descricao}: #{qtd}x\n"
        end
      end

      mensagem = <<~MSG
        #{prefixo}
        
        🏆 *#{challenge.title}*
        
        💰 *Prêmio:* #{challenge.reward}
        #{regras_texto}
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
