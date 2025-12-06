# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Apoiadores
      class << self
        def novo_apoiador(apoiador)
          I18n.t("mensagens.apoiadores.novo",
            nome: apoiador.name,
            whatsapp: apoiador.whatsapp,
            funcao: apoiador.funcao&.name,
            municipio: apoiador.municipio&.name
          )
        end

        def mudanca_funcao(apoiador, funcao_anterior)
          I18n.t("mensagens.apoiadores.mudanca_funcao",
            nome: apoiador.name,
            nova_funcao: apoiador.funcao&.name,
            funcao_anterior: funcao_anterior&.name,
            municipio: apoiador.municipio&.name
          )
        end
      end
    end
  end
end
