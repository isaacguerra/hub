# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Comunicados
      class << self
        def novo_comunicado(comunicado, apoiador)
          lider = comunicado.lider
          regiao_info = comunicado.respond_to?(:regiao) && comunicado.regiao ? "📍 Região: #{comunicado.regiao.name}" : "📍 Geral"
          link = "#{ENV['BASE_URL']}/comunicado/#{comunicado.id}/ler/#{apoiador.id}"

          <<~TEXTO
            📢 *Novo Comunicado*

            *#{comunicado.titulo}*

            #{comunicado.mensagem}

            👤 Enviado por: #{lider&.name}
            #{regiao_info}
            📆 #{comunicado.data.strftime('%d/%m/%Y')}

            🔗 *Confirmar leitura:* #{link}
          TEXTO
        end

        def notificacao_lideranca(comunicado)
          lider = comunicado.lider
          regiao_info = comunicado.respond_to?(:regiao) && comunicado.regiao ? "Região: #{comunicado.regiao.name}" : "Todos"

          <<~TEXTO
            📢 *Comunicado Disparado*

            O líder *#{lider&.name}* enviou um novo comunicado.

            *#{comunicado.titulo}*
            👥 Destino: #{regiao_info}

            📝 Conteúdo:
            #{comunicado.mensagem.truncate(100)}
          TEXTO
        end

        def confirmacao_leitura_apoiador(comunicado, apoiador)
          <<~TEXTO
            ✅ *Leitura Confirmada!*

            Obrigado por confirmar a leitura do comunicado:
            *#{comunicado.titulo}*

            Sua participação é muito importante! 🤝
          TEXTO
        end

        def notificacao_engajamento_criador(comunicado, apoiador)
          <<~TEXTO
            👁️ *Comunicado Lido*

            O apoiador *#{apoiador.name}* confirmou a leitura.

            📄 Comunicado: #{comunicado.titulo}
            📱 WhatsApp: #{apoiador.whatsapp}
          TEXTO
        end

        def notificacao_engajamento_lideranca(comunicado, apoiador)
          municipio = apoiador.municipio

          <<~TEXTO
            📊 *Engajamento em Comunicado*

            O apoiador *#{apoiador.name}* leu o comunicado.

            📄 Comunicado: #{comunicado.titulo}
            📍 #{municipio&.name}
          TEXTO
        end
      end
    end
  end
end
