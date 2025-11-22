module Mobile
  class EstatisticasController < BaseController
    def index
      @total_apoiadores = if Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        Apoiador.count
      elsif Current.apoiador.lider?
        Current.apoiador.subordinados.count
      else
        0
      end

      @total_eventos = Evento.count
      @total_visitas = Visita.count
      @total_convites = Convite.count
    end
  end
end
