# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Convites
      class << self
        # Monta texto para envio de novo convite ao convidado
        def novo_convite(convite, apoiador)
          I18n.t("mensagens.convites.novo",
            nome_convidado: convite.nome,
            nome_apoiador: apoiador&.name,
            link: "#{ENV['BASE_URL']}/convite/aceitar/#{convite.id}"
          )
        end

        # Monta texto para notificar apoiador que seu convite foi aceito
        def convite_aceito(apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          lider = Apoiador.find_by(id: apoiador.lider_id)

          I18n.t("mensagens.convites.aceito",
            nome_apoiador: apoiador.name,
            nome_lider: lider&.name,
            municipio: municipio&.name
          )
        end

        # Monta texto para notificar líder que seu convite foi aceito
        def convite_aceito_lider(apoiador)
          lider = Apoiador.find_by(id: apoiador.lider_id)

          I18n.t("mensagens.convites.aceito_lider",
            nome_lider: lider&.name,
            nome_apoiador: apoiador.name
          )
        end

        # Monta texto para notificar liderança sobre novo convite enviado
        def notificacao_lideranca_novo_convite(convite, apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          funcao = Funcao.find_by(id: apoiador.funcao_id)

          I18n.t("mensagens.convites.notificacao_lideranca_novo",
            nome_apoiador: apoiador.name,
            funcao: funcao&.name,
            municipio: municipio&.name,
            nome_convidado: convite.nome,
            whatsapp_convidado: convite.whatsapp,
            estatisticas: Estatisticas.gerar_convites
          )
        end

        # Monta texto para notificar liderança sobre convite aceito
        def notificacao_lideranca_convite_aceito(apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          bairro = Bairro.find_by(id: apoiador.bairro_id)
          funcao = Funcao.find_by(id: apoiador.funcao_id)
          bairro_info = bairro ? "🏘️ #{bairro.name}" : ""

          I18n.t("mensagens.convites.notificacao_lideranca_aceito",
            nome_apoiador: apoiador.name,
            funcao: funcao&.name,
            municipio: municipio&.name,
            bairro_info: bairro_info,
            estatisticas: Estatisticas.gerar_convites
          )
        end

        # Monta texto para notificar liderança sobre convite recusado
        def notificacao_lideranca_convite_recusado(convite)
          apoiador = Apoiador.find_by(id: convite.enviado_por_id)

          I18n.t("mensagens.convites.notificacao_lideranca_recusado",
            nome_convidado: convite.nome,
            nome_apoiador: apoiador&.name,
            whatsapp_convidado: convite.whatsapp
          )
        end
      end
    end
  end
end
