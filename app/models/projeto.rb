class Projeto < ApplicationRecord
  validates :name, presence: true
  validates :slug, uniqueness: true, allow_nil: true

  has_many :apoiadores, dependent: :restrict_with_exception

  after_create :criar_candidato_e_boas_vindas

  private

  def criar_candidato_e_boas_vindas
    return if candidato_whatsapp.blank? && candidato.blank?

    funcao = Funcao.find_by(name: "Candidato") || Funcao.first

    candidato_apoiador = Apoiador.create!(
      name: candidato.presence || "Candidato",
      whatsapp: candidato_whatsapp,
      funcao: funcao,
      projeto: self
    )

    if candidato_whatsapp.present?
      mensagem = "Bem-vindo, #{candidato_apoiador.name}! Projeto: #{name}"
      SendWhatsappJob.perform_later(whatsapp: candidato_whatsapp, mensagem: mensagem)
    end
  rescue StandardError
    # falha no envio não deve quebrar criação do projeto
    nil
  end
end
