# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Eventos
      class << self
        def novo_evento(evento, apoiador)
          coordenador = evento.coordenador
          municipio = coordenador&.municipio
          link = "#{ENV['BASE_URL']}/evento/#{evento.id}/participar/#{apoiador.id}"

          <<~TEXTO
            📅 *Novo Evento Agendado*

            *#{evento.titulo}*

            📝 #{evento.descricao}
            
            📆 Data: #{evento.data.strftime('%d/%m/%Y às %H:%M')}
            📍 Local: #{evento.local || municipio&.name}

            🎯 Público Alvo: #{evento.descricao_publico_alvo}

            👤 Organizado por: #{coordenador&.name}

            👉 *Confirme sua presença:* #{link}
          TEXTO
        end

        def evento_atualizado(evento)
          coordenador = evento.coordenador

          <<~TEXTO
            🔄 *Evento Atualizado*

            *#{evento.titulo}*

            O evento sofreu alterações.

            📝 #{evento.descricao}
            
            📆 Nova Data: #{evento.data.strftime('%d/%m/%Y às %H:%M')}

            🎯 Público Alvo: #{evento.descricao_publico_alvo}

            👤 Organizado por: #{coordenador&.name}
          TEXTO
        end

        def confirmacao_participacao_apoiador(evento, apoiador)
          <<~TEXTO
            ✅ *Presença Confirmada!*

            Você confirmou presença no evento:
            *#{evento.titulo}*

            📆 #{evento.data.strftime('%d/%m/%Y às %H:%M')}
            📍 #{evento.local}

            Te esperamos lá! 🤝
          TEXTO
        end

        def notificacao_participacao_organizador(evento, apoiador)
          <<~TEXTO
            🙋 *Nova Confirmação de Presença*

            O apoiador *#{apoiador.name}* confirmou presença no seu evento.

            📅 Evento: #{evento.titulo}
            📱 WhatsApp: #{apoiador.whatsapp}
          TEXTO
        end

        def notificacao_participacao_lideranca(evento, apoiador)
          municipio = apoiador.municipio

          <<~TEXTO
            📊 *Participação em Evento*

            O apoiador *#{apoiador.name}* vai participar do evento.

            📅 Evento: #{evento.titulo}
            📍 #{municipio&.name}
          TEXTO
        end
      end
    end
  end
end
