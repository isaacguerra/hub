class Web::HomeController < ApplicationController
  before_action :redirect_mobile_users

  def index
    if Current.apoiador
      @apoiadores = Apoiador.includes(:funcao, :municipio, :regiao, :bairro, :lider, :subordinados, :convites_enviados)

      # Filtros
      @apoiadores = @apoiadores.where("apoiadores.name ILIKE ?", "%#{params[:nome]}%") if params[:nome].present?
      @apoiadores = @apoiadores.where(funcao_id: params[:funcao_id]) if params[:funcao_id].present?
      @apoiadores = @apoiadores.where(municipio_id: params[:municipio_id]) if params[:municipio_id].present?
      @apoiadores = @apoiadores.where(regiao_id: params[:regiao_id]) if params[:regiao_id].present?
      @apoiadores = @apoiadores.where(bairro_id: params[:bairro_id]) if params[:bairro_id].present?

      @apoiadores = @apoiadores.order("apoiadores.created_at DESC")
    end
  end

  private

  def redirect_mobile_users
    if mobile_device?
      redirect_to mobile_root_path
    end
  end
end
