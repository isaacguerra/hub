=begin dd
A modelo o Apoiadores é o principal do projeto
Um Apoiador representa uma pessoa que apoia a campanha eleitoral, podendo ter diversas funções e responsabilidades dentro da organização. Ele deve estar associado a um município, região e bairro específicos, além de ter um líder que o supervisiona. Os apoiadores podem participar de eventos, receber comunicados,
enviar convites e coordenar atividades dentro da campanha. Eles têm diversas associações com outros modelos, como eventos, comunicados e visitas, refletindo sua participação ativa na campanha eleitoral.

Um Apoiador pode ter uma função específica, como Candidato, Coordenador Geral, Coordenador de Município, Coordenador de Região, Coordenador de Bairro, Lider ou simplesmente Apoiador, que é a função inicial. Cada apoiador pode ter subordinados, formando uma hierarquia dentro da organização.
Um Apoiador muda de Funcao de Apoiador para Lider automaticamente apos alcancar 25 apoiadores diretamente subordinados a ele.
Um Apoiador pode receber a funcao de Coordernador Geral, Coordenador de Municipio, Coordenador de Regiao ou Coordenador de Bairro, por um Coordenador Geral o Candidato.
A partir do id do deve haver uma funcao que retorne seus lideres, que sao todos:
    Candidatos, Coordenadores Gerais, Coordenadores de Municipio que ele percence, Coordenadores de Regiao que ele pertence, Coordenadores de Bairro que ele pertence e Lidere que ele pertence.
E tambem uma funcao que retorne todos os apoiadores que ele lidera, sejam eles diretamente ou indiretamente.
Mensageria:
Ao criar um novo Apoiador, devemos gravar uma mensagem no channel mensageria no redis com os dados do novo Apoiador.
Ao Mudar a funcao de um Apoiador devemos gravar uma mensagem no channel mensageria no redis com os dados do Apoiador e sua nova funcao.
    e devemos gravar uma mensagem no channel mensageria informando os lideres do Apoiador que sua rede de apoiadores mudou.
=end

class Apoiador < ApplicationRecord
  include RedeApoiadores
  include Autorizavel
  acts_as_tenant :projeto

  belongs_to :municipio
  belongs_to :regiao
  belongs_to :bairro
  belongs_to :projeto
  belongs_to :funcao
  belongs_to :lider, class_name: "Apoiador", optional: true, counter_cache: :subordinados_count

  alias_attribute :nome, :name

  has_many :subordinados, class_name: "Apoiador", foreign_key: "lider_id"
  alias_method :apoiadores_rede, :subordinados
  has_many :apoiadores_eventos, dependent: :destroy
  has_many :eventos, through: :apoiadores_eventos
  has_many :comunicado_apoiadores, dependent: :destroy
  has_many :comunicados, through: :comunicado_apoiadores
  has_many :convites_enviados, class_name: "Convite", foreign_key: "enviado_por_id", dependent: :destroy
  has_many :linkpaineis, dependent: :destroy
  has_many :veiculos, dependent: :destroy
  has_many :visitas_como_lider, class_name: "Visita", foreign_key: "lider_id", dependent: :destroy
  has_many :visitas_recebidas, class_name: "Visita", foreign_key: "apoiador_id", dependent: :destroy
  has_many :regioes_coordenadas, class_name: "Regiao", foreign_key: "coordenador_id"
  has_many :eventos_coordenados, class_name: "Evento", foreign_key: "coordenador_id", dependent: :destroy
  has_many :comunicados_enviados, class_name: "Comunicado", foreign_key: "lider_id", dependent: :destroy

  # Gamification
  has_one :gamification_point, class_name: "Gamification::Point", dependent: :destroy
  has_many :gamification_action_logs, class_name: "Gamification::ActionLog", dependent: :destroy
  has_many :gamification_apoiador_badges, class_name: "Gamification::ApoiadorBadge", dependent: :destroy
  has_many :gamification_badges, through: :gamification_apoiador_badges, source: :badge
  has_many :gamification_challenge_participants, class_name: "Gamification::ChallengeParticipant", dependent: :destroy
  has_many :gamification_challenges, through: :gamification_challenge_participants, source: :challenge

  validates :name, :whatsapp, presence: true
  validates :municipio, :regiao, :bairro, :funcao, presence: true

  # Callbacks
  before_validation :normalizar_whatsapp
  after_create :notificar_novo_apoiador
  after_create :notificar_convite_aceito, if: :criado_por_convite?
  after_update :verificar_promocao_lider
  after_update :notificar_mudanca_funcao, if: :saved_change_to_funcao_id?
  after_save :atualizar_promocao_lider_superior, if: :saved_change_to_lider_id?

  # Retorna toda a hierarquia de liderança (candidatos, coordenadores, líder direto)
  def hierarquia_lideranca
    Mensageria::Lideranca.buscar_hierarquia(self)
  end

  # Alias mais descritivo para hierarquia_lideranca
  alias_method :lideres, :hierarquia_lideranca

  # Retorna todos os apoiadores subordinados (diretos e indiretos)
  def todos_subordinados(incluir_indiretos: true)
    return subordinados.to_a unless incluir_indiretos

    result = []
    queue = subordinados.to_a

    while queue.any?
      apoiador = queue.shift
      result << apoiador
      queue.concat(apoiador.subordinados.to_a)
    end

    result
  end

  # Conta subordinados diretos
  def total_subordinados_diretos
    subordinados.count
  end

  # Verifica se é candidato
  def candidato?
    funcao_id == Funcao::CANDIDATO_ID
  end

  # Verifica se é coordenador geral
  def coordenador_geral?
    funcao_id == Funcao::COORDENADOR_GERAL_ID
  end

  # Verifica se é coordenador de município
  def coordenador_municipal?
    funcao_id == Funcao::COORDENADOR_MUNICIPAL_ID
  end

  # Verifica se é coordenador de região
  def coordenador_regional?
    funcao_id == Funcao::COORDENADOR_REGIONAL_ID
  end

  # Verifica se é coordenador de bairro
  def coordenador_bairro?
    funcao_id == Funcao::COORDENADOR_BAIRRO_ID
  end

  # Verifica se é líder
  def lider?
    funcao_id == Funcao::LIDER_ID
  end

  # Verifica se é apoiador (função base)
  def apoiador_base?
    funcao_id == Funcao::APOIADOR_ID
  end

  # Verifica se tem permissão para coordenar (qualquer tipo de coordenador ou superior)
  def pode_coordenar?
    e_autorizado?(:coordenar)
  end

  # Gera um código de 6 dígitos, salva e envia via WhatsApp
  def gerar_codigo_acesso!(enviar_whatsapp: true)
    codigo = SecureRandom.random_number(100_000..999_999).to_s
    update_columns(
      verification_code: codigo,
      verification_code_expires_at: 5.minutes.from_now
    )

    Mensageria::Notificacoes::Autenticacao.enviar_codigo(self) if enviar_whatsapp
  end

  # Verifica se o código é válido e não expirou
  def codigo_valido?(codigo)
    return false if verification_code.blank? || verification_code_expires_at.blank?
    return false if Time.current > verification_code_expires_at

    # Compara strings para evitar problemas de tipo
    verification_code.to_s == codigo.to_s
  end

  # Limpa o código após uso bem sucedido
  def limpar_codigo_acesso!
    update!(
      verification_code: nil,
      verification_code_expires_at: nil
    )
  end

  private

  def criado_por_convite?
    # Verifica se foi criado recentemente (less than 1 minute ago)
    # e se existe um convite aceito com mesmo whatsapp
    return false unless created_at > 1.minute.ago

    Convite.exists?(whatsapp: whatsapp, status: "aceito")
  end

  def notificar_novo_apoiador
    Mensageria::Notificacoes::Apoiadores.notificar_novo_apoiador(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar novo apoiador #{id}: #{e.message}"
  end

  def notificar_convite_aceito
    Mensageria::Notificacoes::Convites.notificar_convite_aceito(self)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar convite aceito para apoiador #{id}: #{e.message}"
  end

  def verificar_promocao_lider
    # Verifica se deve ser promovido automaticamente a Líder
    return unless funcao_id == Funcao::APOIADOR_ID
    return unless total_subordinados_diretos >= 25

    update_column(:funcao_id, Funcao::LIDER_ID)
    Rails.logger.info "Apoiador #{id} promovido automaticamente a Líder"
  end
  def atualizar_promocao_lider_superior
    # Quando um apoiador ganha/perde subordinados, verifica se o líder deve ser promovido
    return unless lider_id.present?

    lider.verificar_promocao_lider if lider
  rescue StandardError => e
    Rails.logger.error "Erro ao verificar promoção do líder #{lider_id}: #{e.message}"
  end

  def notificar_mudanca_funcao
    Mensageria::Notificacoes::Apoiadores.notificar_mudanca_funcao(self, funcao_id_before_last_save)
  rescue StandardError => e
    Rails.logger.error "Erro ao notificar mudança de função do apoiador #{id}: #{e.message}"
  end

  def normalizar_whatsapp
    self.whatsapp = Utils::NormalizaNumeroWhatsapp.format(whatsapp)
  end

  def foto_perfil_url
    Utils::BuscaImagemWhatsapp.buscar(whatsapp)
  end

  public :foto_perfil_url
end
