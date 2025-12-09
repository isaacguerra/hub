module Gamification
  class ChallengeService
    # Chamado sempre que uma ação pontuável ocorre
    def self.check_progress(apoiador, action_type)
      # Busca desafios ativos que ainda não foram completados
      active_challenges = Gamification::Challenge
                            .where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current)
                            .where(completed_at: nil)

      active_challenges.each do |challenge|
        # Verifica se a ação é relevante para o desafio
        rules = challenge.rules || {}
        next unless rules.key?(action_type.to_s)

        # Busca ou cria registro de participação
        participant = Gamification::ChallengeParticipant.find_or_create_by(
          challenge: challenge,
          apoiador: apoiador
        )

        # Atualiza progresso
        current_progress = participant.progress || {}
        current_count = (current_progress[action_type.to_s] || 0).to_i
        new_count = current_count + 1

        current_progress[action_type.to_s] = new_count
        participant.progress = current_progress
        participant.save!

        # Verifica se completou TODAS as regras
        if check_completion(challenge, participant)
          declare_winner(challenge, apoiador)
        end
      end
    end

    private

    def self.check_completion(challenge, participant)
      rules = challenge.rules || {}
      progress = participant.progress || {}

      rules.all? do |action, target|
        (progress[action.to_s] || 0).to_i >= target.to_i
      end
    end

    def self.declare_winner(challenge, apoiador)
      # Lock para evitar race condition se dois completarem ao mesmo tempo
      challenge.with_lock do
        return if challenge.completed_at.present? # Já tem vencedor

        challenge.update!(
          winner: apoiador,
          completed_at: Time.current
        )
      end

      # Dispara notificação de vencedor
      Gamification::AnnounceWinnerJob.perform_later(challenge.id)
    end
  end
end
