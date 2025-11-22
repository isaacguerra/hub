# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Autenticacao
      class << self
        def codigo_acesso(codigo)
          <<~TEXTO
            🔐 *Seu Código de Acesso*

            Use o código abaixo para entrar no App Ivone:

            *#{codigo}*

            ⚠️ Este código é válido por 5 minutos.
            Não compartilhe com ninguém.
          TEXTO
        end

        def link_magico(link)
          <<~TEXTO
            🔐 *Acesso ao App Ivone*

            Toque no link abaixo para entrar automaticamente:

            #{link}

            ⚠️ Este link é válido por 5 minutos.
            Não compartilhe com ninguém.
          TEXTO
        end
      end
    end
  end
end
