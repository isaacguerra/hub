# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Visitas
      class << self
        # Monta texto para notificar apoiador sobre nova visita agendada
        def nova_visita(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          I18n.t("mensagens.visitas.nova",
            nome_visitado: apoiador_visitado&.name,
            nome_lider: apoiador_lider&.name,
            whatsapp_lider: apoiador_lider&.whatsapp
          )
        end

        # Monta texto para notificar líder sobre visita que deve fazer
        def nova_visita_lider(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)
          lider = Apoiador.find_by(id: apoiador_visitado&.lider_id)
          municipio = Municipio.find_by(id: apoiador_visitado&.municipio_id)
          bairro = Bairro.find_by(id: apoiador_visitado&.bairro_id)

          bairro_info = bairro ? bairro.name : "N/A"

          I18n.t("mensagens.visitas.nova_lider",
            nome_lider: apoiador_lider&.name,
            nome_visitado: apoiador_visitado&.name,
            whatsapp_visitado: apoiador_visitado&.whatsapp,
            nome_lider_apoiador: lider&.name,
            municipio: municipio&.name,
            bairro: bairro_info
          )
        end

        # Monta texto para notificar apoiador que a visita foi realizada
        def visita_realizada(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          I18n.t("mensagens.visitas.realizada",
            nome_visitado: apoiador_visitado&.name,
            nome_lider: apoiador_lider&.name
          )
        end

        # Monta texto para notificar liderança sobre nova visita agendada
        def notificacao_lideranca_nova_visita(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          municipio = Municipio.find_by(id: apoiador&.municipio_id)
          bairro = Bairro.find_by(id: apoiador&.bairro_id)
          funcao = Funcao.find_by(id: apoiador&.funcao_id)
          lider = Apoiador.find_by(id: visita.lider_id)
          lider_funcao = Funcao.find_by(id: lider&.funcao_id)

          bairro_info = bairro ? "🏘️ Bairro: #{bairro.name}" : ""

          I18n.t("mensagens.visitas.notificacao_lideranca_nova",
            nome_visitado: apoiador&.name,
            funcao_visitado: funcao&.name,
            municipio: municipio&.name,
            bairro_info: bairro_info,
            nome_lider: lider&.name,
            whatsapp_lider: lider&.whatsapp,
            funcao_lider: lider_funcao&.name
          )
        end

        # Monta texto para notificar liderança sobre visita realizada
        def notificacao_lideranca_visita_realizada(visita)
          apoiador_visita = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)
          lider_municipio = Municipio.find_by(id: lider&.municipio_id)

          I18n.t("mensagens.visitas.notificacao_lideranca_realizada",
            nome_lider: lider&.name,
            nome_visitado: apoiador_visita&.name,
            relato: visita.relato,
            municipio_lider: lider_municipio&.name
          )
        end

        # Monta texto para notificar cancelamento de visita
        def visita_cancelada(visita)
          apoiador_visitado = Apoiador.find_by(id: visita.apoiador_id)
          apoiador_lider = Apoiador.find_by(id: visita.lider_id)

          I18n.t("mensagens.visitas.cancelada",
            nome_visitado: apoiador_visitado&.name,
            nome_lider: apoiador_lider&.name
          )
        end

        # Monta texto para notificar liderança sobre visita cancelada
        def notificacao_lideranca_visita_cancelada(visita)
          apoiador = Apoiador.find_by(id: visita.apoiador_id)
          lider = Apoiador.find_by(id: visita.lider_id)

          I18n.t("mensagens.visitas.notificacao_lideranca_cancelada",
            nome_lider: lider&.name,
            nome_visitado: apoiador&.name
          )
        end
      end
    end
  end
end
