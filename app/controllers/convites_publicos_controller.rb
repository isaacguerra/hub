class ConvitesPublicosController < ApplicationController
  skip_before_action :authenticate_apoiador!
  layout "auth"

  before_action :set_convite, only: %i[show accept]
  before_action :check_convite_status, only: %i[show accept]

  def show
    @apoiador = Apoiador.new(
      name: @convite.nome,
      whatsapp: @convite.whatsapp
    )
    load_auxiliary_data
  end

  def accept
    @apoiador = Apoiador.new(apoiador_params)
    @apoiador.name = params[:apoiador][:nome] || @convite.nome
    @apoiador.whatsapp = @convite.whatsapp # Garante que usa o whats do convite
    @apoiador.lider_id = @convite.enviado_por_id

    # Define função padrão "Apoiador"
    @apoiador.funcao_id = Funcao::APOIADOR_ID

    if @apoiador.save
      @convite.update(status: "aceito")

      # Dispara notificações de boas-vindas e avisos à liderança
      Mensageria::Notificacoes::Convites.notificar_convite_aceito(@apoiador)

      redirect_to sucesso_convite_path
    else
      load_auxiliary_data
      render :show, status: :unprocessable_entity
    end
  end

  def success
  end

  private

  def set_convite
    @convite = Convite.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to login_path, alert: "Convite não encontrado."
  end

  def check_convite_status
    unless @convite.status == "pendente"
      redirect_to login_path, alert: "Este convite já foi utilizado ou expirou."
    end
  end

  def load_auxiliary_data
    @municipios = Municipio.order(:name)
    @regioes = Regiao.order(:name)
    @bairros = Bairro.order(:name)
  end

  def apoiador_params
    params.require(:apoiador).permit(
      :email, :municipio_id, :regiao_id, :bairro_id, :nome
    )
  end
end
