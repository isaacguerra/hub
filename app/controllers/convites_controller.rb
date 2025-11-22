class ConvitesController < ApplicationController
  before_action :set_convite, only: %i[ show edit update destroy ]

  # GET /convites or /convites.json
  def index
    @convites = Convite.all
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
    # Use callbacks to share common setup or constraints between actions.
    def set_convite
      @convite = Convite.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def convite_params
      params.expect(convite: [ :nome, :whatsapp, :status, :enviado_por_id ])
    end
end
