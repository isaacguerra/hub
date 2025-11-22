module Mobile
  class PerfilController < BaseController
    # mostre o perfil do apoiador atual com os dados pessoais
    # com detalhes e relacionamentos
    # mostre a rede de apoiadores conectados e lideres
    # convites enviados com status
    # visitas recebidas
    # use um card para cada seção
    def show
      @apoiador = Current.apoiador
    end
  end
end
