module Gamification
  class RankingWorker < ApplicationJob
    queue_as :default

    def perform(period)
      # period pode ser 'daily', 'weekly', 'monthly'
      winner_data = Gamification::RankingService.winner(period: period)
      
      return unless winner_data

      apoiador = winner_data[:apoiador]
      points = winner_data[:points]

      # Notifica o vencedor
      notify_winner(apoiador, points, period)
      
      # Opcional: Notificar administradores ou grupo geral
      # notify_general_group(apoiador, points, period)
    end

    private

    def notify_winner(apoiador, points, period)
      period_text = case period.to_s
                    when 'daily' then "do dia"
                    when 'weekly' then "da semana"
                    when 'monthly' then "do mês"
                    else "do período"
                    end

      mensagem = "Parabéns #{apoiador.name}! 🏆\n" \
                 "Você foi o Apoiador #{period_text} com #{points} pontos conquistados!\n" \
                 "Continue assim para ganhar mais prêmios e destaque na campanha."

      # Integração com Mensageria (usando a estrutura existente)
      # Assumindo que existe um método genérico ou criando um específico
      
      # Se não existir classe específica, usamos o Logger ou criamos uma notificação ad-hoc
      # Aqui estou simulando a chamada conforme padrão do projeto
      
      imagem_url = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)
      
      Mensageria::Logger.log_mensagem_apoiador(
        fila: "mensageria",
        image_url: imagem_url,
        whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
        mensagem: mensagem
      )
    rescue StandardError => e
      Rails.logger.error "Erro ao notificar vencedor do ranking #{period}: #{e.message}"
    end
  end
end
