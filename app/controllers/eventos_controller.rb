class EventosController < ApplicationController
  before_action :set_evento, only: %i[ show edit update destroy ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_manage, only: %i[ edit update destroy ]

  # GET /eventos or /eventos.json
  def index
    @eventos = Evento.all.order(data: :desc)
  end

  # GET /eventos/1 or /eventos/1.json
  def show
    @participantes = @evento.apoiadores.includes(:municipio, :bairro).order(:nome)
  end

  # GET /eventos/new
  def new
    @evento = Evento.new
  end

  # GET /eventos/1/edit
  def edit
  end

  # POST /eventos or /eventos.json
  def create
    @evento = Evento.new(evento_params)
    @evento.coordenador = Current.apoiador

    respond_to do |format|
      if @evento.save
        format.html { redirect_to @evento, notice: "Evento was successfully created." }
        format.json { render :show, status: :created, location: @evento }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @evento.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /eventos/1 or /eventos/1.json
  def update
    respond_to do |format|
      if @evento.update(evento_params)
        format.html { redirect_to @evento, notice: "Evento was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @evento }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @evento.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /eventos/1 or /eventos/1.json
  def destroy
    @evento.destroy!

    respond_to do |format|
      format.html { redirect_to eventos_path, notice: "Evento was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evento
      @evento = Evento.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def evento_params
      params.expect(evento: [
        :titulo, :data, :local, :descricao,
        :link_whatsapp, :link_instagram, :link_facebook, :link_tiktok,
        :filtro_funcao_id, :filtro_municipio_id, :filtro_regiao_id, :filtro_bairro_id
      ])
    end

    def authorize_create
      unless Current.apoiador.pode_coordenar? || Current.apoiador.lider?
        redirect_to eventos_path, alert: "Você não tem permissão para criar eventos."
      end
    end

    def authorize_manage
      can_manage = Current.apoiador.candidato? ||
                   Current.apoiador.coordenador_geral? ||
                   @evento.coordenador_id == Current.apoiador.id

      unless can_manage
        redirect_to eventos_path, alert: "Você não tem permissão para gerenciar este evento."
      end
    end
end
