# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Eventos
      class << self
        def novo_evento(evento, apoiador)
          coordenador = evento.coordenador
          municipio = coordenador&.municipio
          link = "#{ENV['BASE_URL']}/evento/#{evento.id}/participar/#{apoiador.id}"

          I18n.t("mensagens.eventos.novo",
            titulo: evento.titulo,
            descricao: evento.descricao,
            data: evento.data.strftime("%d/%m/%Y às %H:%M"),
            local: evento.local || municipio&.name,
            publico_alvo: evento.descricao_publico_alvo,
            nome_organizador: coordenador&.name,
            link: link
          )
        end

        def evento_atualizado(evento)
          coordenador = evento.coordenador

          I18n.t("mensagens.eventos.atualizado",
            titulo: evento.titulo,
            descricao: evento.descricao,
            data: evento.data.strftime("%d/%m/%Y às %H:%M"),
            publico_alvo: evento.descricao_publico_alvo,
            nome_organizador: coordenador&.name
          )
        end

        def confirmacao_participacao_apoiador(evento, apoiador)
          I18n.t("mensagens.eventos.confirmacao_participacao",
            titulo: evento.titulo,
            data: evento.data.strftime("%d/%m/%Y às %H:%M"),
            local: evento.local
          )
        end

        def notificacao_participacao_organizador(evento, apoiador)
          I18n.t("mensagens.eventos.notificacao_participacao_organizador",
            nome_apoiador: apoiador.name,
            titulo: evento.titulo,
            whatsapp_apoiador: apoiador.whatsapp
          )
        end

        def notificacao_participacao_lideranca(evento, apoiador)
          municipio = apoiador.municipio

          I18n.t("mensagens.eventos.notificacao_participacao_lideranca",
            nome_apoiador: apoiador.name,
            titulo: evento.titulo,
            municipio: municipio&.name
          )
        end
      end
    end
  end
end
