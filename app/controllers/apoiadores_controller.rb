class ApoiadoresController < ApplicationController
  before_action :set_apoiador, only: %i[ show edit update destroy ]

  # GET /apoiadores or /apoiadores.json
  def index
    @apoiadores = scope_apoiadores
  end

  # GET /apoiadores/1 or /apoiadores/1.json
  def show
  end

  # GET /apoiadores/1/edit
  def edit
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
    def scope_apoiadores
      if Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        Apoiador.all
      elsif Current.apoiador.coordenador_municipal?
        Apoiador.where(municipio_id: Current.apoiador.municipio_id)
      elsif Current.apoiador.coordenador_regional?
        Apoiador.where(regiao_id: Current.apoiador.regiao_id)
      elsif Current.apoiador.coordenador_bairro?
        Apoiador.where(bairro_id: Current.apoiador.bairro_id)
      elsif Current.apoiador.lider?
        Current.apoiador.subordinados
      else
        Apoiador.where(id: Current.apoiador.id)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_apoiador
      @apoiador = scope_apoiadores.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def apoiador_params
      permitted = [ :nome, :whatsapp, :email, :endereco, :bairro_id, :municipio_id, :regiao_id, :lider_id ]
      permitted << :funcao_id if Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
      params.expect(apoiador: permitted)
    end
end
