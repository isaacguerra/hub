# webhook que recebe uma chamada post vinda do evolution
# quando uma mensagem chega para o chatbot
# receberemos um json com os dados da mensagem
# [
#   {
#     "headers": {
#       "host": "app-n8n-postgres.rvcfiu.easypanel.host",
#       "user-agent": "axios/1.12.2",
#       "content-length": "1446",
#       "accept": "application/json, text/plain, */*",
#       "accept-encoding": "gzip, compress, deflate, br",
#       "content-type": "application/json",
#       "x-forwarded-for": "172.18.0.1",
#       "x-forwarded-host": "app-n8n-postgres.rvcfiu.easypanel.host",
#       "x-forwarded-port": "443",
#       "x-forwarded-proto": "https",
#       "x-forwarded-server": "5bd87ecee310",
#       "x-real-ip": "172.18.0.1"
#     },
#     "params": {},
#     "query": {},
#     "body": {
#       "event": "messages.upsert",
#       "instance": "ivone",
#       "data": {
#         "key": {
#           "remoteJid": "559684094117@s.whatsapp.net",
#           "remoteJidAlt": "144401179349242@lid",
#           "fromMe": false,
#           "id": "AC806F6328567893BA04045AEF43B473",
#           "participant": "",
#           "addressingMode": "pn"
#         },
#         "pushName": "Isaac Guerra",
#         "status": "DELIVERY_ACK",
#         "message": {
#           "conversation": "Ola",
#           "messageContextInfo": {
#             "deviceListMetadata": {
#               "senderKeyIndexes": [],
#               "recipientKeyIndexes": [],
#               "senderKeyHash": {
#                 "0": 116,
#                 "1": 125,
#                 "2": 90,
#                 "3": 169,
#                 "4": 193,
#                 "5": 133,
#                 "6": 228,
#                 "7": 194,
#                 "8": 226,
#                 "9": 184
#               },
#               "senderTimestamp": {
#                 "low": 1764855692,
#                 "high": 0,
#                 "unsigned": true
#               },
#               "recipientKeyHash": {
#                 "0": 107,
#                 "1": 165,
#                 "2": 210,
#                 "3": 1,
#                 "4": 229,
#                 "5": 223,
#                 "6": 75,
#                 "7": 156,
#                 "8": 181,
#                 "9": 7
#               },
#               "recipientTimestamp": {
#                 "low": 1765023845,
#                 "high": 0,
#                 "unsigned": true
#               }
#             },
#             "deviceListMetadataVersion": 2,
#             "messageSecret": {
#               "0": 57,
#               "1": 125,
#               "2": 64,
#               "3": 12,
#               "4": 162,
#               "5": 45,
#               "6": 83,
#               "7": 199,
#               "8": 69,
#               "9": 47,
#               "10": 124,
#               "11": 167,
#               "12": 79,
#               "13": 69,
#               "14": 58,
#               "15": 35,
#               "16": 251,
#               "17": 78,
#               "18": 75,
#               "19": 222,
#               "20": 35,
#               "21": 145,
#               "22": 241,
#               "23": 247,
#               "24": 205,
#               "25": 114,
#               "26": 89,
#               "27": 157,
#               "28": 193,
#               "29": 183,
#               "30": 8,
#               "31": 145
#             }
#           }
#         },
#         "messageType": "conversation",
#         "messageTimestamp": 1765023983,
#         "instanceId": "82edaab5-7f2e-425b-8b13-c0d0029d7057",
#         "source": "android"
#       },
#       "destination": "https://app-n8n-postgres.rvcfiu.easypanel.host/webhook-test/29d0b1ee-5d35-4c0e-b1df-b74cc377ea0f",
#       "date_time": "2025-12-06T09:26:23.597Z",
#       "sender": "559684079887@s.whatsapp.net",
#       "server_url": "http://localhost:8080",
#       "apikey": "1C577D45766E-420D-91E0-3C2B3D95989A"
#     },
#     "webhookUrl": "https://app-n8n-postgres.rvcfiu.easypanel.host/webhook-test/29d0b1ee-5d35-4c0e-b1df-b74cc377ea0f",
#     "executionMode": "test"
#   }
# ]
# temos que filtrar e retornar somente os campos que nos interessam
# event, instance, data.key.remoteJid, data.pushName, data.message, data.messageType, data.messageTimestamp, source
# depois, processar a mensagem conforme a lógica do chatbot
# a partir do remoteJid formatar usando format_chatbot_number
# buscar um Apiador com esse número
# se encontrar, processar a mensagem com a funcao chatboot_start passando o apoiador e a mensagem
# se não encontrar, retronar uma mensagem padrão dizendo que o número não está cadastrado via mensageria/notificacoes/chatbot.rb
# finalmente, retornar status 200 OK para o evolution

module Api
  module Chatbot
    class WebhookController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_apoiador!

      def receive
        payload = params[:body] || params

        if payload["event"] != "messages.upsert"
          Rails.logger.info "Ignorando evento: #{payload["event"]}"
          head :ok
          return
        end

        # Criar um objeto com os dados relevantes do payload
        message = {
          event: payload["event"],
          instance: payload["instance"],
          remote_jid: payload.dig("data", "key", "remoteJid"),
          push_name: payload.dig("data", "pushName"),
          message_content: payload.dig("data", "message"),
          message_type: payload.dig("data", "messageType"),
          message_timestamp: payload.dig("data", "messageTimestamp"),
          source: payload.dig("data", "source")
        }

        # Formatar o número do WhatsApp
        whatsapp_number = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(message[:remote_jid])

        if whatsapp_number.blank?
          render json: { error: "Número de WhatsApp inválido" }, status: :bad_request
          return
        end

        apoiador = Apoiador.find_by(whatsapp: whatsapp_number)

        if apoiador
          # Passamos o objeto message completo para ter acesso ao message_type
          ChatbotStart.start(apoiador: apoiador, message_data: message)
        else
          Mensageria::Notificacoes::Chatbot.notificar_numero_nao_cadastrado(whatsapp_number, message[:push_name])
        end
        head :ok
      rescue StandardError => e
        Rails.logger.error "Erro ao processar webhook do chatbot: #{e.message}"
        render json: { error: e.message, backtrace: e.backtrace }, status: :internal_server_error
      end
    end
  end
end
