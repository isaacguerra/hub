module Autorizavel
  extend ActiveSupport::Concern

  def e_autorizado?(acao, objeto = nil)
    AutorizacaoRegras.pode?(self, acao, objeto)
  end
end
