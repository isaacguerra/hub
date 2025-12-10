class Web::ComunicadosController < ApplicationController
  before_action :set_comunicado, only: %i[ show edit update destroy ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_manage, only: %i[ edit update destroy ]

  # GET /comunicados or /comunicados.json
  def index
    @comunicados = Comunicado.all.order(created_at: :desc)
  end

  # GET /comunicados/1 or /comunicados/1.json
  def show
    @engajados = @comunicado.apoiadores
                            .includes(:municipio, :bairro)
                            .where(comunicado_apoiadores: { engajado: true })
                            .order(:nome)
  end

  # GET /comunicados/new
  def new
    @comunicado = Comunicado.new
  end

  # GET /comunicados/1/edit
  def edit
  end

  # POST /comunicados or /comunicados.json
  def create
    @comunicado = Comunicado.new(comunicado_params)
    @comunicado.lider = Current.apoiador

    respond_to do |format|
      if @comunicado.save
        format.html { redirect_to @comunicado, notice: "Comunicado was successfully created." }
        format.json { render :show, status: :created, location: @comunicado }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comunicado.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comunicados/1 or /comunicados/1.json
  def update
    respond_to do |format|
      if @comunicado.update(comunicado_params)
        format.html { redirect_to @comunicado, notice: "Comunicado was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @comunicado }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comunicado.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comunicados/1 or /comunicados/1.json
  def destroy
    @comunicado.destroy!

    respond_to do |format|
      format.html { redirect_to comunicados_path, notice: "Comunicado was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comunicado
      @comunicado = Comunicado.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def comunicado_params
      params.expect(comunicado: [ :titulo, :mensagem, :data ])
    end

    def authorize_create
      unless Current.apoiador.pode_coordenar? || Current.apoiador.lider?
        redirect_to comunicados_path, alert: "Você não tem permissão para criar comunicados."
      end
    end

    def authorize_manage
      can_manage = Current.apoiador.candidato? ||
                   Current.apoiador.coordenador_geral? ||
                   @comunicado.lider_id == Current.apoiador.id

      unless can_manage
        redirect_to comunicados_path, alert: "Você não tem permissão para gerenciar este comunicado."
      end
    end
end
