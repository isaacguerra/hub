class Web::SessionsController < ApplicationController
  skip_before_action :authenticate_apoiador!, only: %i[new create verify verify_view]
  layout "auth", only: %i[new create verify verify_view]

  # GET /login
  def new
  end

  # POST /sessions (Etapa 1: Enviar WhatsApp)
  def create
    whatsapp = Utils::NormalizaNumeroWhatsapp.format(params[:whatsapp])
    @apoiador = Apoiador.find_by(whatsapp: whatsapp)

    if @apoiador
      @apoiador.gerar_codigo_acesso!
      # Armazena temporariamente o ID para a próxima etapa (poderia ser na sessão ou hidden field)
      session[:auth_apoiador_id] = @apoiador.id

      respond_to do |format|
        format.html { redirect_to sessions_verify_path }
        format.json { render json: { message: "Código enviado", apoiador_id: @apoiador.id }, status: :ok }
      end
    else
      flash.now[:alert] = "Número não encontrado. Verifique se digitou corretamente ou entre em contato com seu líder."
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { error: "Número não encontrado" }, status: :not_found }
      end
    end
  end

  # GET /sessions/verify
  def verify_view
    render :verify
  end

  # POST /sessions/verify (Etapa 2: Verificar Código)
  def verify
    apoiador_id = params[:apoiador_id] || session[:auth_apoiador_id]
    @apoiador = Apoiador.find_by(id: apoiador_id)
    codigo = params[:codigo]

    if @apoiador && @apoiador.codigo_valido?(codigo)
      @apoiador.limpar_codigo_acesso!
      session[:apoiador_id] = @apoiador.id
      session.delete(:auth_apoiador_id)

      # Pontuar login diário
      Gamification::PointsService.award_points(
        apoiador: @apoiador,
        action_type: "daily_login"
      )

      if mobile_device?
        redirect_to mobile_root_path, notice: "Bem-vindo, #{@apoiador.name}!"
      else
        redirect_to root_path, notice: "Bem-vindo, #{@apoiador.name}!"
      end
    else
      flash.now[:alert] = "Código inválido ou expirado."
      render :verify, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    session[:apoiador_id] = nil
    redirect_to login_path, notice: "Você saiu do sistema."
  end
end
