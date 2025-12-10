class Web::BairrosController < ApplicationController
  before_action :authorize_admin!
  before_action :set_context
  before_action :set_bairro, only: %i[ show edit update destroy ]

  # GET /bairros or /bairros.json
  def index
    @bairros = @regiao.bairros
  end

  # GET /bairros/1 or /bairros/1.json
  def show
  end

  # GET /bairros/new
  def new
    @bairro = @regiao.bairros.build
  end

  # GET /bairros/1/edit
  def edit
  end

  # POST /bairros or /bairros.json
  def create
    @bairro = @regiao.bairros.build(bairro_params)

    respond_to do |format|
      if @bairro.save
        format.html { redirect_to municipio_regiao_bairro_path(@municipio, @regiao, @bairro), notice: "Bairro criado com sucesso." }
        format.json { render :show, status: :created, location: @bairro }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bairro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bairros/1 or /bairros/1.json
  def update
    respond_to do |format|
      if @bairro.update(bairro_params)
        format.html { redirect_to municipio_regiao_bairro_path(@municipio, @regiao, @bairro), notice: "Bairro atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @bairro }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bairro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bairros/1 or /bairros/1.json
  def destroy
    @bairro.destroy!

    respond_to do |format|
      format.html { redirect_to municipio_regiao_path(@municipio, @regiao), status: :see_other, notice: "Bairro excluído com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    def set_context
      @municipio = Municipio.find(params[:municipio_id])
      @regiao = @municipio.regioes.find(params[:regiao_id])
    end

    def set_bairro
      @bairro = @regiao.bairros.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bairro_params
      params.expect(bairro: [ :name, :regiao_id ])
    end

    def authorize_admin!
      unless Current.apoiador.e_autorizado?(:admin)
        redirect_to root_path, alert: "Acesso não autorizado."
      end
    end
end
