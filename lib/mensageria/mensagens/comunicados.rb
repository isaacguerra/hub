# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Comunicados
      class << self
        def novo_comunicado(comunicado)
          lider = comunicado.lider
          regiao_info = comunicado.regiao ? "📍 Região: #{comunicado.regiao.name}" : "📍 Geral"

          <<~TEXTO
            📢 *Novo Comunicado*

            *#{comunicado.titulo}*

            #{comunicado.mensagem}

            👤 Enviado por: #{lider&.name}
            #{regiao_info}
            📆 #{comunicado.data.strftime('%d/%m/%Y')}
          TEXTO
        end

        def notificacao_lideranca(comunicado)
          lider = comunicado.lider
          regiao_info = comunicado.regiao ? "Região: #{comunicado.regiao.name}" : "Todos"

          <<~TEXTO
            📢 *Comunicado Disparado*

            O líder *#{lider&.name}* enviou um novo comunicado.

            *#{comunicado.titulo}*
            👥 Destino: #{regiao_info}
            
            📝 Conteúdo:
            #{comunicado.mensagem.truncate(100)}
          TEXTO
        end
      end
    end
  end
end
