class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_apoiador
  before_action :set_current_tenant
  before_action :authenticate_apoiador!

  helper_method :mobile_device?

  private

  def set_current_apoiador
    if session[:apoiador_id]
      Current.apoiador = Apoiador.find_by(id: session[:apoiador_id])
    end
  end

  def set_current_tenant
    if Current.apoiador && Current.apoiador.projeto
      ActsAsTenant.current_tenant = Current.apoiador.projeto
    else
      ActsAsTenant.current_tenant = nil
    end
  end

  after_action do
    ActsAsTenant.current_tenant = nil
  end

  def authenticate_apoiador!
    unless Current.apoiador
      redirect_to login_path, alert: "Você precisa estar logado para acessar essa página."
    end
  end

  def mobile_device?
    request.user_agent =~ /Mobile|webOS|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
  end
end
