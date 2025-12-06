# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Comunicados
      class << self
        def novo_comunicado(comunicado, apoiador)
          lider = comunicado.lider
          regiao_info = comunicado.respond_to?(:regiao) && comunicado.regiao ? "📍 Região: #{comunicado.regiao.name}" : "📍 Geral"
          link = "#{ENV['BASE_URL']}/comunicado/#{comunicado.id}/ler/#{apoiador.id}"

          I18n.t("mensagens.comunicados.novo",
            titulo: comunicado.titulo,
            mensagem: comunicado.mensagem,
            nome_lider: lider&.name,
            regiao_info: regiao_info,
            data: comunicado.data.strftime("%d/%m/%Y"),
            link: link
          )
        end

        def notificacao_lideranca(comunicado)
          lider = comunicado.lider
          regiao_info = comunicado.respond_to?(:regiao) && comunicado.regiao ? "Região: #{comunicado.regiao.name}" : "Todos"

          I18n.t("mensagens.comunicados.notificacao_lideranca",
            nome_lider: lider&.name,
            titulo: comunicado.titulo,
            regiao_info: regiao_info,
            conteudo_truncado: comunicado.mensagem.truncate(100)
          )
        end

        def confirmacao_leitura_apoiador(comunicado, apoiador)
          I18n.t("mensagens.comunicados.confirmacao_leitura", titulo: comunicado.titulo)
        end

        def notificacao_engajamento_criador(comunicado, apoiador)
          I18n.t("mensagens.comunicados.notificacao_engajamento_criador",
            nome_apoiador: apoiador.name,
            titulo_comunicado: comunicado.titulo,
            whatsapp_apoiador: apoiador.whatsapp
          )
        end

        def notificacao_engajamento_lideranca(comunicado, apoiador)
          municipio = apoiador.municipio

          I18n.t("mensagens.comunicados.notificacao_engajamento_lideranca",
            nome_apoiador: apoiador.name,
            titulo_comunicado: comunicado.titulo,
            municipio: municipio&.name
          )
        end
      end
    end
  end
end
