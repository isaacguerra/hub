module Mobile
  class ApoiadoresController < BaseController
    before_action :set_apoiador, only: %i[edit update destroy]
    before_action :authorize_create, only: %i[new create]
    before_action :authorize_manage, only: %i[edit update destroy]
    before_action :load_auxiliary_data, only: %i[new create edit update]

    def index
      @apoiadores = scope_apoiadores.includes(:funcao, :municipio, :regiao, :bairro, :lider).order(:nome)
    end

    def new
      @apoiador = Apoiador.new
    end

    def create
      @apoiador = Apoiador.new(apoiador_params)
      # Se quem cria é líder ou coordenador, define ele como líder do novo apoiador,
      # a menos que seja admin definindo outro líder (mas vamos simplificar)
      @apoiador.lider = Current.apoiador unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?

      # Define senha padrão ou gera aleatória se necessário, mas aqui vamos assumir que o model lida ou é via magic link depois
      # Mas para salvar precisa de validação? Vamos tentar salvar.

      if @apoiador.save
        redirect_to mobile_apoiadores_path, notice: "Apoiador cadastrado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @apoiador.update(apoiador_params)
        redirect_to mobile_apoiadores_path, notice: "Apoiador atualizado com sucesso."
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

    def set_apoiador
      @apoiador = scope_apoiadores.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to mobile_apoiadores_path, alert: "Apoiador não encontrado ou sem permissão."
    end

    def apoiador_params
      params.require(:apoiador).permit(:nome, :email, :whatsapp, :nascimento, :cep, :endereco, :numero, :complemento, :bairro_id, :municipio_id)
    end

    def load_auxiliary_data
      @bairros = Bairro.order(:nome)
      @municipios = Municipio.order(:nome)
    end

    def authorize_create
      unless Current.apoiador.pode_coordenar? || Current.apoiador.lider?
        redirect_to mobile_apoiadores_path, alert: "Você não tem permissão para cadastrar apoiadores."
      end
    end

    def authorize_manage
      # A lógica de escopo no set_apoiador já garante que só edita quem vê.
      # Mas podemos adicionar restrições extras se necessário.
    end
  end
end
