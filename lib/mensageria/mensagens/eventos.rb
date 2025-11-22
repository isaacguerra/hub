# frozen_string_literal: true

module Mensageria
  module Mensagens
    module Eventos
      class << self
        def novo_evento(evento)
          coordenador = evento.coordenador
          municipio = coordenador&.municipio

          <<~TEXTO
            📅 *Novo Evento Agendado*

            *#{evento.titulo}*

            📝 #{evento.descricao}

            📆 Data: #{evento.data.strftime('%d/%m/%Y às %H:%M')}
            📍 Local: #{municipio&.name}

            👤 Organizado por: #{coordenador&.name}
          TEXTO
        end

        def evento_atualizado(evento)
          coordenador = evento.coordenador

          <<~TEXTO
            🔄 *Evento Atualizado*

            *#{evento.titulo}*

            O evento sofreu alterações.

            📝 #{evento.descricao}
            📆 Nova Data: #{evento.data.strftime('%d/%m/%Y às %H:%M')}

            👤 Organizado por: #{coordenador&.name}
          TEXTO
        end
      end
    end
  end
end
