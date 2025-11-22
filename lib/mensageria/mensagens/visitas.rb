# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Visitas
      class << self
        # Monta texto para notificar apoiador sobre nova visita agendada
        def nova_visita(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          <<~TEXTO
            🏠 *Olá #{apoiador_visitado&.name}!*

            👋 Seu amigo *#{apoiador_lider&.name}* gostaria de fazer uma visita para conhecê-lo melhor e conversar sobre como você pode se envolver mais com o nosso grupo.

            Vou encaminhar seu contato para ele entrar em contato e combinar a visita.

            📱 WhatsApp do líder que vai visitá-lo: #{apoiador_lider&.whatsapp}

            🤝 Estamos ansiosos para fortalecer nossa comunidade juntos!
          TEXTO
        end

        # Monta texto para notificar líder sobre visita que deve fazer
        def nova_visita_lider(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)
          lider = Apoiador.find_by(id: apoiador_visitado&.lider_id)
          municipio = Municipio.find_by(id: apoiador_visitado&.municipio_id)
          bairro = Bairro.find_by(id: apoiador_visitado&.bairro_id)

          bairro_info = bairro ? bairro.name : 'N/A'

          <<~TEXTO
            🏠 *Olá #{apoiador_lider&.name}!*

            👋 Você deve fazer uma visita ao apoiador *#{apoiador_visitado&.name}*.

            📋 *Dados de contato:*
            📱 WhatsApp do apoiador: #{apoiador_visitado&.whatsapp}
            👤 Líder do apoiador: #{lider&.name}
            📍 Município: #{municipio&.name}
            🏘️ Bairro: #{bairro_info}

            🤝 Vamos fortalecer nossa comunidade juntos!
          TEXTO
        end

        # Monta texto para notificar apoiador que a visita foi realizada
        def visita_realizada(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          <<~TEXTO
            ✅ *Olá #{apoiador_visitado&.name}!*

            👋 Seu amigo *#{apoiador_lider&.name}* realizou a visita que vocês combinaram!

            Espero que tenham tido uma ótima conversa sobre como você pode se envolver mais com o nosso grupo. 🤝
          TEXTO
        end

        # Monta texto para notificar liderança sobre nova visita agendada
        def notificacao_lideranca_nova_visita(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          municipio = Municipio.find_by(id: apoiador&.municipio_id)
          bairro = Bairro.find_by(id: apoiador&.bairro_id)
          funcao = Funcao.find_by(id: apoiador&.funcao_id)
          lider = Apoiador.find_by(id: visita.lider_id)
          lider_funcao = Funcao.find_by(id: lider&.funcao_id)

          bairro_info = bairro ? "🏘️ Bairro: #{bairro.name}" : ''

          <<~TEXTO
            🏠 *Nova Visita Solicitada*

            👤 *Quem será visitado:*
            #{apoiador&.name}
            #{funcao&.name}
            📍 #{municipio&.name}
            #{bairro_info}

            🎯 *Líder que o visitará:*
            Nome: #{lider&.name}
            📱 WhatsApp: #{lider&.whatsapp}
            #{lider_funcao&.name}
          TEXTO
        end

        # Monta texto para notificar liderança sobre visita realizada
        def notificacao_lideranca_visita_realizada(visita)
          apoiador_visita = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)
          lider_funcao = Funcao.find_by(id: lider&.funcao_id)
          lider_municipio = Municipio.find_by(id: lider&.municipio_id)

          <<~TEXTO
            ✅ *Visita Realizada*

            O Líder *#{lider&.name}* realizou a visita ao apoiador *#{apoiador_visita&.name}*.

            📝 *Relato:*
            #{visita.relato}

            📍 #{lider_municipio&.name}
          TEXTO
        end

        # Monta texto para notificar cancelamento de visita
        def visita_cancelada(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          <<~TEXTO
            ❌ *Visita Cancelada*

            Olá #{apoiador_visitado&.name},

            A visita agendada com *#{apoiador_lider&.name}* foi cancelada.

            Entraremos em contato em breve para reagendar.
          TEXTO
        end

        # Monta texto para notificar liderança sobre visita cancelada
        def notificacao_lideranca_visita_cancelada(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)

          <<~TEXTO
            ❌ *Visita Cancelada*

            A visita do líder *#{lider&.name}* ao apoiador *#{apoiador&.name}* foi cancelada.
          TEXTO
        end
      end
    end
  end
end
