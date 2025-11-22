# frozen_string_literal: true

module Mensageria
  module Helpers
    class << self
      def format_phone_number(phone)
        return nil if phone.blank?

        # Remove todos os caracteres não numéricos
        digits = phone.gsub(/\D/, '')

        # Garante que tenha código do país (55 para Brasil)
        digits = "55#{digits}" unless digits.start_with?('55')

        # Formato: 55DDNNNNNNNNN (55 + DDD + número)
        digits
      end
    end
  end
end
