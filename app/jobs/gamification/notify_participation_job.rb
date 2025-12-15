module Gamification
  class NotifyParticipationJob < ApplicationJob
    queue_as :default

    def perform(participant_id)
      participant = ::Gamification::ChallengeParticipant.find(participant_id)
      apoiador_entrou = participant.apoiador
      challenge = participant.challenge

      # Mensagem para toda a base
      mensagem = <<~MSG
        🚀 *Novo Participante na Missão!*

        #{apoiador_entrou.name} acabou de aceitar o desafio:
        *#{challenge.title}*

        Não fique de fora! Participe você também e concorra a:
        🏆 #{challenge.reward}

        Acesse agora: #{ENV.fetch('BASE_URL', 'https://app.ivonechagas.com.br')}/mobile/gamification/#{challenge.id}
      MSG

      # Envia para todos os apoiadores (exceto quem acabou de entrar, para não receber msg redundante)
      Apoiador.where.not(id: apoiador_entrou.id).find_each do |apoiador|
        SendWhatsappJob.perform_later(whatsapp: apoiador.whatsapp, mensagem: mensagem, projeto_id: apoiador.projeto_id)
      end

      # Envia mensagem específica de confirmação para quem entrou
      msg_confirmacao = "Parabéns! Você está participando da missão *#{challenge.title}*. Boa sorte!"
      SendWhatsappJob.perform_later(whatsapp: apoiador_entrou.whatsapp, mensagem: msg_confirmacao, projeto_id: apoiador_entrou.projeto_id)
    end
  end
end
