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

        # Caso 4: Número com DDI mas sem DDD (conforme lógica original, embora estranho para 12 digitos)
        # Exemplo: 55991120579 (falta o 96) - Nota: O exemplo original tinha 11 digitos mas a logica checava 12.
        # Mantendo a lógica do TS: if (cleaned.length === 12 && cleaned.startsWith('55'))
        if cleaned.length == 12 && cleaned.start_with?("55")
          return "5596#{cleaned[2..]}"
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

      def format_chatbot_number(whatsapp)
        return nil if whatsapp.blank?

        full = whatsapp.to_s
        numero = full.split("@")[0] # remove o domínio

        # Lógica específica para números vindos do ChatBot que faltam o nono dígito
        ddd = numero[0..3]      # Pega os 4 primeiros caracteres (ex: "5596")
        nono_digito = "9"
        restante = numero[4..]  # Pega do 5º caractere em diante

        "#{ddd}#{nono_digito}#{restante}"
      end
    end
  end
end
