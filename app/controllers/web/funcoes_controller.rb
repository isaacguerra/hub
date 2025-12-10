class Web::FuncoesController < ApplicationController
  before_action :set_funcao, only: %i[ show edit update destroy ]

  # GET /funcoes or /funcoes.json
  def index
    @funcoes = Funcao.all
  end

  # GET /funcoes/1 or /funcoes/1.json
  def show
  end

  # GET /funcoes/new
  def new
    @funcao = Funcao.new
  end

  # GET /funcoes/1/edit
  def edit
  end

  # POST /funcoes or /funcoes.json
  def create
    @funcao = Funcao.new(funcao_params)

    respond_to do |format|
      if @funcao.save
        format.html { redirect_to @funcao, notice: "Funcao was successfully created." }
        format.json { render :show, status: :created, location: @funcao }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @funcao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /funcoes/1 or /funcoes/1.json
  def update
    respond_to do |format|
      if @funcao.update(funcao_params)
        format.html { redirect_to @funcao, notice: "Funcao was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @funcao }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @funcao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /funcoes/1 or /funcoes/1.json
  def destroy
    @funcao.destroy!

    respond_to do |format|
      format.html { redirect_to funcoes_path, notice: "Funcao was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_funcao
      @funcao = Funcao.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def funcao_params
      params.expect(funcao: [ :nome, :descricao ])
    end
end
