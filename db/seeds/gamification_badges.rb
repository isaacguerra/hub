# Badges Iniciais do Sistema de Gamificação

badges = [
  {
    key: "primeiro_convite",
    name: "Primeiro Passo",
    description: "Enviou o primeiro convite para um amigo.",
    criteria: { action_type: "convite_sent", count: 1 },
    image_url: "badges/primeiro_convite.png"
  },
  {
    key: "convidador_bronze",
    name: "Convidador Bronze",
    description: "Teve 5 convites aceitos.",
    criteria: { action_type: "convite_accepted", count: 5 },
    image_url: "badges/convidador_bronze.png"
  },
  {
    key: "convidador_prata",
    name: "Convidador Prata",
    description: "Teve 25 convites aceitos.",
    criteria: { action_type: "convite_accepted", count: 25 },
    image_url: "badges/convidador_prata.png"
  },
  {
    key: "convidador_ouro",
    name: "Convidador Ouro",
    description: "Teve 100 convites aceitos.",
    criteria: { action_type: "convite_accepted", count: 100 },
    image_url: "badges/convidador_ouro.png"
  },
  {
    key: "visitador_ativo",
    name: "Visitador Ativo",
    description: "Realizou 10 visitas.",
    criteria: { action_type: "visit_created", count: 10 },
    image_url: "badges/visitador_ativo.png"
  },
  {
    key: "engajado_semanal",
    name: "Super Engajado",
    description: "Engajou com 5 comunicados.",
    criteria: { action_type: "comunicado_engaged", count: 5 },
    image_url: "badges/engajado.png"
  },
  {
    key: "participante_eventos",
    name: "Presença Confirmada",
    description: "Participou de 3 eventos.",
    criteria: { action_type: "event_participation", count: 3 },
    image_url: "badges/evento.png"
  }
]

badges.each do |badge_data|
  Gamification::Badge.find_or_create_by!(key: badge_data[:key]) do |badge|
    badge.name = badge_data[:name]
    badge.description = badge_data[:description]
    badge.criteria = badge_data[:criteria]
    badge.image_url = badge_data[:image_url]
  end
end

puts "Badges de gamificação criadas/atualizadas com sucesso!"
