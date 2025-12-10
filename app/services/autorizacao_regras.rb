class AutorizacaoRegras
  def self.pode?(apoiador, acao, objeto = nil)
    return false unless apoiador

    case acao
    when :admin
      apoiador.funcao_id.in?([Funcao::CANDIDATO_ID, Funcao::COORDENADOR_GERAL_ID])
    when :coordenar
      apoiador.funcao_id.in?([
        Funcao::CANDIDATO_ID, 
        Funcao::COORDENADOR_GERAL_ID, 
        Funcao::COORDENADOR_MUNICIPAL_ID, 
        Funcao::COORDENADOR_REGIONAL_ID, 
        Funcao::COORDENADOR_BAIRRO_ID
      ])
    when :liderar
      pode?(apoiador, :coordenar) || apoiador.funcao_id == Funcao::LIDER_ID
    when :criar_evento, :criar_visita, :criar_comunicado
      pode?(apoiador, :liderar)
    when :gerenciar_evento
      return true if pode?(apoiador, :admin)
      return false unless objeto
      objeto.coordenador_id == apoiador.id
    when :gerenciar_visita
      return true if pode?(apoiador, :admin)
      return false unless objeto
      objeto.lider_id == apoiador.id
    when :gerenciar_comunicado
      return true if pode?(apoiador, :admin)
      return false unless objeto
      objeto.lider_id == apoiador.id
    else
      false
    end
  end
end
