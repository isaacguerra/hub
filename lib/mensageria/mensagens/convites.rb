# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Convites
      class << self
        # Monta texto para envio de novo convite ao convidado
        def novo_convite(convite, apoiador)
          <<~TEXTO
            🎉 *Olá #{convite.nome}!*

            👋 Seu amigo *#{apoiador&.name}* lhe enviou esse convite.

            🤝 Somos o *Grupo de Ação Amigos da Ivone Chagas*

            ✨ Sua presença será muito importante para nós!

            👉 Por favor, confirme sua presença no link abaixo:

            🔗 #{ENV['BASE_URL']}/convite/aceitar/#{convite.id}
          TEXTO
        end

        # Monta texto para notificar apoiador que seu convite foi aceito
        def convite_aceito(apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          lider = Apoiador.find_by(id: apoiador.lider_id)

          <<~TEXTO
            🎊 *Que Legal voce Aceitou Nosso Convite*

            ✅ *Agora #{apoiador.name} voce é um novo membro de nossa Equipe!

            👤 *Convidado por:*
            #{lider&.name}
            📍 #{municipio&.name}

            🎯 *Próximos passos importantes:*
            • Convidar outros amigos, ter 25 pessoas participando do Grupo vai fazer voce se tornar um lider importante de nosso Projeto!
            • Se voce for o maior Lider de sua cidade voce se Torna Coordenador Municipal
            • Quanto mais Apoiadores voce Convidar mais voce crescerá em nosso Grupo, que tal ser um Coordenador Geral, ou um Coordenador de Regiao! Basta convidar pessoas, Fazer visitas, e participar dos
            • Envolver nas atividades do grupo
            • Integrar ao nosso time

            Vamos recebê-lo(a) com muito carinho! 🤝

            Agora voce ja pode acessar o Sistema de Admistracao onde poderá:
            • Convidar novos Apoiadores
            • Acompanhar os Eventos e Comunicaçoes
            • Ver seu Perfil

            Para receber o link de acesso a pagina de Administracao basta nesse mesmo whatsapp mandar uma mensagem com um "Ola" voce receberá um link de acesso para sua pagina de administracao!
            • Tente agora diga "Ola" e comece a Convidar mais Pessoas para esse projeto!

            • Do mais é cada um fazer sua parte para "Melhorarmos o Amapá Junstos"!

            • Aqui vc tembém será informado de tudo que está acontecendo em Nosso Grupo, sempre de uma olhada nas atividadades!
          TEXTO
        end

        # Monta texto para notificar líder que seu convite foi aceito
        def convite_aceito_lider(apoiador)
          lider = Apoiador.find_by(id: apoiador.lider_id)

          <<~TEXTO
            🎊 *Parabéns #{lider&.name}!*

            O Apoiador *#{apoiador.name}* aceitou o convite!

            Agora é hora de fazer uma visita de boas-vindas e integrar ele ao nosso time! 🤝
          TEXTO
        end

        # Monta texto para notificar liderança sobre novo convite enviado
        def notificacao_lideranca_novo_convite(convite, apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          funcao = Funcao.find_by(id: apoiador.funcao_id)

          <<~TEXTO
            📩 *Novo Convite Enviado*

            👤 *Enviado por:*
            #{apoiador.name}
            #{funcao&.name}
            📍 #{municipio&.name}

            🎯 *Convidado:*
            Nome: #{convite.nome}
            📱 WhatsApp: #{convite.whatsapp}

            #{Estatisticas.gerar_convites}
          TEXTO
        end

        # Monta texto para notificar liderança sobre convite aceito
        def notificacao_lideranca_convite_aceito(apoiador)
          municipio = Municipio.find_by(id: apoiador.municipio_id)
          bairro = Bairro.find_by(id: apoiador.bairro_id)
          funcao = Funcao.find_by(id: apoiador.funcao_id)

          <<~TEXTO
            🎊 *Convite Aceito!*

            O Apoiador *#{apoiador.name}* aceitou o convite e agora faz parte do time!

            👤 *Dados:*
            #{funcao&.name}
            📍 #{municipio&.name}
            #{bairro ? "🏘️ #{bairro.name}" : ''}

            #{Estatisticas.gerar_convites}
          TEXTO
        end

        # Monta texto para notificar liderança sobre convite recusado
        def notificacao_lideranca_convite_recusado(convite)
          apoiador = Apoiador.find_by(id: convite.enviado_por_id)
          
          <<~TEXTO
            ❌ *Convite Recusado*

            O convite enviado para *#{convite.nome}* foi recusado.

            👤 *Enviado por:* #{apoiador&.name}
            📱 WhatsApp Convidado: #{convite.whatsapp}
          TEXTO
        end
      end
    end
  end
end
