class ApoiadoresController < ApplicationController
  before_action :set_apoiador, only: %i[ show edit update destroy ]

  # GET /apoiadores or /apoiadores.json
  def index
    @apoiadores = Apoiador.all
  end

  # GET /apoiadores/1 or /apoiadores/1.json
  def show
  end

  # GET /apoiadores/new
  def new
    @apoiador = Apoiador.new
  end

  # GET /apoiadores/1/edit
  def edit
  end

  # POST /apoiadores or /apoiadores.json
  def create
    @apoiador = Apoiador.new(apoiador_params)

    respond_to do |format|
      if @apoiador.save
        format.html { redirect_to @apoiador, notice: "Apoiador was successfully created." }
        format.json { render :show, status: :created, location: @apoiador }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @apoiador.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apoiadores/1 or /apoiadores/1.json
  def update
    respond_to do |format|
      if @apoiador.update(apoiador_params)
        format.html { redirect_to @apoiador, notice: "Apoiador was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @apoiador }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @apoiador.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apoiadores/1 or /apoiadores/1.json
  def destroy
    @apoiador.destroy!

    respond_to do |format|
      format.html { redirect_to apoiadores_path, notice: "Apoiador was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_apoiador
      @apoiador = Apoiador.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def apoiador_params
      params.expect(apoiador: [ :nome, :whatsapp, :email, :endereco, :bairro_id, :municipio_id, :regiao_id, :funcao_id, :lider_id ])
    end
end
