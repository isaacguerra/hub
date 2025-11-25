class RegioesController < ApplicationController
  before_action :authorize_admin!
  before_action :set_municipio
  before_action :set_regiao, only: %i[ show edit update destroy ]

  # GET /regioes or /regioes.json
  def index
    @regioes = @municipio.regioes
  end

  # GET /regioes/1 or /regioes/1.json
  def show
  end

  # GET /regioes/new
  def new
    @regiao = @municipio.regioes.build
  end

  # GET /regioes/1/edit
  def edit
  end

  # POST /regioes or /regioes.json
  def create
    @regiao = @municipio.regioes.build(regiao_params)

    respond_to do |format|
      if @regiao.save
        format.html { redirect_to municipio_regiao_path(@municipio, @regiao), notice: "Região criada com sucesso." }
        format.json { render :show, status: :created, location: @regiao }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @regiao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regioes/1 or /regioes/1.json
  def update
    respond_to do |format|
      if @regiao.update(regiao_params)
        format.html { redirect_to municipio_regiao_path(@municipio, @regiao), notice: "Região atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @regiao }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @regiao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regioes/1 or /regioes/1.json
  def destroy
    @regiao.destroy!

    respond_to do |format|
      format.html { redirect_to municipio_path(@municipio), status: :see_other, notice: "Região excluída com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    def set_municipio
      @municipio = Municipio.find(params[:municipio_id])
    end

    def set_regiao
      @regiao = @municipio.regioes.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def regiao_params
      params.expect(regiao: [ :name, :municipio_id, :coordenador_id ])
    end

    def authorize_admin!
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to root_path, alert: "Acesso não autorizado."
      end
    end
end
