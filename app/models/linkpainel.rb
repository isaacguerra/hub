# == Schema Information
# Um LinkPainel representa um link personalizado para o painel de um Apoiador
# usaremos o slug para gerar o link unico para o painel do Apoiador
# usaremos o whatsapp do apoiador para authenticação no painel
# caso o Apoiador estiver cadastrador, ou seja que exita um whtasapp vinculado ao Apoiador, criaremos um slug usando o BASE_URL + slug que usaremos para acessar o painel do Apoiador
# ao criar um LinkPainel devemos garantir que o slug seja unico no sistema
# ele deve devolver um Apoiador associado ao slug validado pelo whatsapp
# um LinkPainel pertence a um Apoiador
# um LinkPainel deve ser criado com status ativo
# se o Apoiador for desativado, o LinkPainel deve ser desativado também
# um LinkPainel quando ativo deve ser acessivel por 2 minutos, apos esse tempo o LinkPainel deve ser expirado e o Apoiador deve gerar um novo LinkPainel para acessar o painel novamente
# se um linkpainel for expirado, o status deve ser atualizado para expirado
# se o Apoiador acessar o LinkPainel antes de expirar, o status deve ser atualizado para usado e deve durar 30 minutos apos esse tempo deve ganhar o status expirado
# quando um LinkPainel for acessado devemos registrar o ip do Apoiador que acessou o LinkPainel e o horário de acesso
# caso o Apoiador mude de ip o link deve expirar imediatamente e o status deve ser atualizado para expirado
# quando um Apoiador acessar o linkPainel devemos criar um varialvel de sessao com Apoiador.current e usaremos para validar o Apoiador autenticado em toda a aplicacao, para o Apoiador com duração de 30 minutos
# quando o linkPainel tiver o status publico, devemos devolver o Apoiador.current e a url que o controller sera redirecionado para a url registrada no LinkPainel

class Linkpainel < ApplicationRecord
  belongs_to :apoiador

  validates :slug, :url, :status, presence: true
  validates :apoiador, presence: true
  validates :slug, uniqueness: true
  validates :status, inclusion: { in: %w[ativo usado expirado inativo] }

  # Callbacks
  before_validation :gerar_slug, on: :create
  before_validation :definir_status_inicial, on: :create

  # Scopes
  scope :ativos, -> { where(status: 'ativo').where('created_at > ?', 2.minutes.ago) }
  scope :usados_validos, -> { where(status: 'usado').where('updated_at > ?', 30.minutes.ago) }
  scope :validos, -> { ativos.or(usados_validos) }

  # Gera URL completa para o painel
  def url_completa
    "#{ENV['BASE_URL']}/#{slug}"
  end

  # Verifica se o link está válido
  def valido?
    case status
    when 'ativo'
      created_at > 2.minutes.ago
    when 'usado'
      updated_at > 30.minutes.ago
    else
      false
    end
  end

  # Marca como usado e registra IP
  def marcar_como_usado!(ip)
    return false unless status == 'ativo' && valido?

    update(status: 'usado', real_ip: ip)
  end

  # Verifica se o IP mudou e expira se necessário
  def validar_ip(ip)
    if status == 'usado' && real_ip.present? && real_ip != ip
      expirar!
      return false
    end
    true
  end

  # Expira o link
  def expirar!
    update(status: 'expirado')
  end

  # Auto-expirar links antigos
  def self.expirar_links_antigos
    Linkpainel.where(status: 'ativo').where('created_at < ?', 2.minutes.ago).update_all(status: 'expirado')
    Linkpainel.where(status: 'usado').where('updated_at < ?', 30.minutes.ago).update_all(status: 'expirado')
  end

  private

  def gerar_slug
    return if slug.present?

    loop do
      self.slug = SecureRandom.urlsafe_base64(8)
      break unless Linkpainel.exists?(slug: slug)
    end
  end

  def definir_status_inicial
    self.status = 'ativo' if status.blank?
  end
end
