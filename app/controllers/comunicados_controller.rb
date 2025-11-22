class ComunicadosController < ApplicationController
  before_action :set_comunicado, only: %i[ show edit update destroy ]

  # GET /comunicados or /comunicados.json
  def index
    @comunicados = Comunicado.all
  end

  # GET /comunicados/1 or /comunicados/1.json
  def show
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
      params.expect(comunicado: [ :titulo, :mensagem, :data, :lider_id, :imagem, :link_whatsapp, :link_instagram, :link_facebook, :link_tiktok ])
    end
end
