# frozen_string_literal: true

module Utils
  module NormalizaNumeroWhatsapp
    class << self
      def format(phone)
        return nil if phone.blank?

        # Remove todos os caracteres não numéricos
        cleaned = phone.gsub(/\D/, "")

        # Remove o zero inicial do DDD se presente (ex: 096 -> 96)
        cleaned = cleaned[1..] if cleaned.start_with?("0")

        # Caso 1: Número com 8 dígitos (formato antigo sem o 9 inicial)
        # Exemplo: 91120579 -> 5596991120579
        if cleaned.length == 8
          return "55969#{cleaned}"
        end

        # Caso 2: Número com 9 dígitos (já tem o 9 inicial)
        # Exemplo: 991120579 -> 5596991120579
        if cleaned.length == 9
          return "5596#{cleaned}"
        end

        # Caso 3: Número com DDD (10 ou 11 dígitos)
        if cleaned.length == 10
          # Tem DDD mas sem o 9 inicial
          # Exemplo: 9691120579 -> 5596991120579
          return "55#{cleaned[0..1]}9#{cleaned[2..]}"
        end

        if cleaned.length == 11
          # Tem DDD e o 9 inicial
          # Exemplo: 96991120579 -> 5596991120579
          return "55#{cleaned}"
        end

        # Caso 4: Número com 12 dígitos começando com 55 (DDI + DDD + 8 dígitos)
        # Exemplo: 559691120579 -> 5596991120579
        if cleaned.length == 12 && cleaned.start_with?("55")
          ddd = cleaned[2..3]
          numero = cleaned[4..]
          return "55#{ddd}9#{numero}"
        end

        # Caso 5: Já está no formato completo
        # Exemplo: 5596991120579
        if cleaned.length == 13 && cleaned.start_with?("5596")
          return cleaned
        end

        # Caso 6: Tem DDI mas DDD diferente de 96, mantém o DDD original
        if cleaned.length == 13 && cleaned.start_with?("55")
          return cleaned
        end

        # Se nenhum dos casos acima, tenta adicionar prefixo completo
        # Remove prefixos parciais se existirem
        if cleaned.start_with?("5596")
          cleaned = cleaned[4..]
        elsif cleaned.start_with?("55")
          cleaned = cleaned[2..]
        elsif cleaned.start_with?("96")
          cleaned = cleaned[2..]
        end

        # Garante que tem 9 dígitos
        if cleaned.length == 8
          cleaned = "9#{cleaned}"
        end

        # Adiciona prefixo completo
        "5596#{cleaned}"
      end

      # temos que garantir que o numero whatsapp cadastrado do Apoiador seja no formato aceito pelo whatsapp business api
      # na funcao format acima quando cadastramos o apoiador via sistema web
      # porem quando o numero vem do ChatBot pode ser que ele venha em um formato diferente
      # por exemplo o ChatBot pode enviar o numero sem o nono digito
      # ou sem o DDI OU DDD
      # entao essa funcao tenta corrigir esses casos especificos do ChatBot
      # para garantir que o numero fique no formato correto
      # 5596991120579 ou seja DDI 55 + DDD 96 + nono digito 9 + numero 91120579
      # exemplo de entrada do ChatBot: 9691120579 (sem o nono digito)
      # ou 991120579 (sem DDI e DDD)
      # ou 91120579 (sem DDI, DDD e nono digito)
      # essa funcao deve ser usada apenas para numeros vindos do ChatBot
      # e deve normalizar o numero para o formato correto
      # exemplo de uso:
      # numero_formatado = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(whatsapp)
      # onde whatsapp é o numero vindo do ChatBot
      # e retorna o numero no formato correto
      # exemplo de retorno: 5596991120579
      # garanta que essa funcao normalize o numero corretamente
      # apos a normalizacao use a funcao format para garantir o formato final
      def format_chatbot_number(whatsapp)
        return nil if whatsapp.blank?

        # Remove domínio e caracteres não numéricos
        # O split("@") remove sufixos como @c.us ou @s.whatsapp.net
        numero = whatsapp.to_s.split("@")[0].gsub(/\D/, "")

        # Casos de entrada:
        case numero.length
        when 8
          # Só número, sem nono dígito, DDD, DDI
          numero = "55969#{numero}"
        when 9
          # Sem DDI/DDD, mas já tem nono dígito
          numero = "5596#{numero}"
        when 10
          # DDD + número sem nono dígito
          numero = "55#{numero[0..1]}9#{numero[2..]}"
        when 11
          # DDD + número com nono dígito
          numero = "55#{numero}"
        when 12
          # DDI + DDD + número sem nono dígito (Ex: 55 96 8409 4117)
          # Ou DDI + número sem DDD (Ex: 55 99112 0579) - menos provável se vier do WhatsApp
          
          if numero.start_with?("55")
             # Assume que é DDI 55 + DDD + 8 dígitos
             # Ex: 559684094117 -> 5596984094117
             ddd = numero[2..3]
             resto = numero[4..]
             numero = "55#{ddd}9#{resto}"
          else
             # Se não começa com 55, assume DDI + número sem DDD (raro)
             numero = "5596#{numero[2..]}"
          end
        when 13
          # Já está no formato correto ou tem DDI/DDDs diferentes
          # Se não começar com 5596, força para 5596
          numero = numero.start_with?("5596") ? numero : "5596#{numero[-9..]}"
        else
          # Se vier em formato inesperado, tenta forçar para 5596 + últimos 9 dígitos
          numero = "5596#{numero[-9..]}"
        end

        # Garante formato final
        format(numero)
      end
    end
  end
end
