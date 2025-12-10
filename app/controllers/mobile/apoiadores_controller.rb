module Mobile
  class ApoiadoresController < BaseController
    before_action :set_apoiador, only: %i[show edit update destroy card]
    before_action :authorize_manage, only: %i[edit update destroy]
    before_action :load_auxiliary_data, only: %i[edit update]

    def index
      @apoiadores = scope_apoiadores.includes(:funcao, :municipio, :regiao, :bairro, :lider).order(:nome)
      @apoiadores = @apoiadores.where("name ILIKE ?", "%#{params[:nome]}%") if params[:nome].present?
    end

    def show
      @gamification = ::Gamification::Point.find_or_create_by(apoiador: @apoiador)

      # Calculate Level Progress
      current_level_info = ::Gamification::Level.find_by(level: @gamification.level)
      next_level_info = ::Gamification::Level.find_by(level: @gamification.level + 1)

      @xp_current = @gamification.points
      @xp_next = next_level_info&.experience_threshold || @xp_current
      @xp_start = current_level_info&.experience_threshold || 0

      total_range = @xp_next - @xp_start
      @progress_percent = total_range > 0 ? ((@xp_current - @xp_start) / total_range.to_f * 100).clamp(0, 100) : 100

      @rede = @apoiador.rede_completa

      @visitas_count = @apoiador.visitas_recebidas.count
      @visitas_recentes = @apoiador.visitas_recebidas.order(data: :desc).limit(3)

      @eventos_count = @apoiador.eventos.count
      @eventos_recentes = @apoiador.eventos.order(data_hora: :desc).limit(3)

      @missoes_count = @apoiador.gamification_challenges.count
      @missoes_recentes = @apoiador.gamification_challenges.limit(3)

      @comunicados_recentes = @apoiador.comunicados.order(created_at: :desc).limit(3)

      @convites_count = @apoiador.convites_enviados.count

      @badges = ::Gamification::ApoiadorBadge.where(apoiador: @apoiador).includes(:badge)
      @challenges_won = ::Gamification::Challenge.where(winner: @apoiador)
      @weekly_wins = ::Gamification::WeeklyWinner.where(apoiador: @apoiador).order(week_end_date: :desc)

      render layout: "mobile_profile"
    end

    def card
      render partial: "card", locals: { apoiador: @apoiador }
    end

    def edit
    end

    def update
      if @apoiador.update(apoiador_params)
        redirect_to mobile_apoiador_path(@apoiador), notice: "Apoiador atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @apoiador.destroy
      redirect_to mobile_apoiadores_path, notice: "Apoiador removido com sucesso."
    end

    private

    def scope_apoiadores
      if Current.apoiador.e_autorizado?(:admin)
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

    def set_apoiador
      @apoiador = scope_apoiadores.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to mobile_apoiadores_path, alert: "Apoiador não encontrado ou sem permissão."
    end

    def apoiador_params
      permitted = [ :nome, :email, :whatsapp, :nascimento, :cep, :endereco, :numero, :complemento, :bairro_id, :municipio_id ]
      permitted << :funcao_id if Current.apoiador.e_autorizado?(:admin)
      params.require(:apoiador).permit(permitted)
    end

    def load_auxiliary_data
      @bairros = Bairro.order(:nome)
      @municipios = Municipio.order(:nome)
    end

    def authorize_manage
      # A lógica de escopo no set_apoiador já garante que só edita quem vê.
      # Mas podemos adicionar restrições extras se necessário.
    end
  end
end
