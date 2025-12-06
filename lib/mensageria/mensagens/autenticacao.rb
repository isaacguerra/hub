# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Autenticacao
      class << self
        def codigo_acesso(codigo)
          I18n.t("mensagens.autenticacao.codigo_acesso", codigo: codigo)
        end

        def link_magico(link)
          I18n.t("mensagens.autenticacao.link_magico", link: link)
        end
      end
    end
  end
end
