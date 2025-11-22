# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Apoiadores
      class << self
        def novo_apoiador(apoiador)
          <<~TEXTO
            🎉 *Novo Apoiador Cadastrado*

            #{apoiador.name}
            📱 #{apoiador.whatsapp}
            🎯 #{apoiador.funcao&.name}
            📍 #{apoiador.municipio&.name}
          TEXTO
        end

        def mudanca_funcao(apoiador, funcao_anterior)
          <<~TEXTO
            🎯 *Atualização de Função*

            #{apoiador.name} agora é *#{apoiador.funcao&.name}*!

            Função anterior: #{funcao_anterior&.name}
            📍 #{apoiador.municipio&.name}
          TEXTO
        end
      end
    end
  end
end
