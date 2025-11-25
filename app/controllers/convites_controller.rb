class ConvitesController < ApplicationController
  before_action :set_convite, only: %i[ show edit update destroy ]
  before_action :authorize_manage, only: %i[ edit update destroy ]

  # GET /convites or /convites.json
  def index
    @convites = scope_convites.order(created_at: :desc)
  end

  # GET /convites/1 or /convites/1.json
  def show
  end

  # GET /convites/new
  def new
    @convite = Convite.new
  end

  # GET /convites/1/edit
  def edit
  end

  # POST /convites or /convites.json
  def create
    @convite = Convite.new(convite_params)
    @convite.enviado_por = Current.apoiador
    @convite.status = "pendente"

    respond_to do |format|
      if @convite.save
        format.html { redirect_to @convite, notice: "Convite was successfully created." }
        format.json { render :show, status: :created, location: @convite }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @convite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /convites/1 or /convites/1.json
  def update
    respond_to do |format|
      if @convite.update(convite_params)
        format.html { redirect_to @convite, notice: "Convite was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @convite }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @convite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /convites/1 or /convites/1.json
  def destroy
    @convite.destroy!

    respond_to do |format|
      format.html { redirect_to convites_path, notice: "Convite was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def scope_convites
      if Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        Convite.all
      elsif Current.apoiador.coordenador_municipal?
        Convite.joins(:enviado_por).where(apoiadores: { municipio_id: Current.apoiador.municipio_id })
      elsif Current.apoiador.coordenador_regional?
        Convite.joins(:enviado_por).where(apoiadores: { regiao_id: Current.apoiador.regiao_id })
      elsif Current.apoiador.coordenador_bairro?
        Convite.joins(:enviado_por).where(apoiadores: { bairro_id: Current.apoiador.bairro_id })
      elsif Current.apoiador.lider?
        subordinados_ids = Current.apoiador.todos_subordinados(incluir_indiretos: true).map(&:id)
        Convite.where(enviado_por_id: subordinados_ids + [ Current.apoiador.id ])
      else
        Convite.where(enviado_por_id: Current.apoiador.id)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_convite
      @convite = scope_convites.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def convite_params
      params.expect(convite: [ :nome, :whatsapp ])
    end

    def authorize_manage
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to convites_path, alert: "Sem permissão para gerenciar convites."
      end
    end
end
