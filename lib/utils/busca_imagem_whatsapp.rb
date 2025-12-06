# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Utils
  module BuscaImagemWhatsapp
    class << self
      def buscar(numero_whatsapp)
        perfil = Utils::BuscaPerfilWhatsapp.buscar(numero_whatsapp)
        perfil ? perfil[:picture] : nil
      end
    end
  end
end
