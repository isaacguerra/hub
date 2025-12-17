puts "Iniciando o seed..."

# Criar Projeto padrão (antes de criar apoiadores)
default_name = "Ivone Chagas"
projeto = Projeto.find_or_create_by!(name: default_name) do |p|
  p.candidato = "Ivone Chagas"
  p.candidato_whatsapp = '5596984102020'
  p.descricao = 'Campanha Ivone Chagas'
  p.site = 'https://ivonechagas.example'
  p.slug = 'ivone-chagas'
  p.active = true
end
puts "Projeto padrão criado: #{projeto.name} (id=#{projeto.id})"

# 1. Criar Funções
funcoes = {
  Funcao::CANDIDATO_ID => 'Candidato',
  Funcao::COORDENADOR_GERAL_ID => 'Coordenador Geral',
  Funcao::COORDENADOR_REGIONAL_ID => 'Coordenador de Região',
  Funcao::COORDENADOR_MUNICIPAL_ID => 'Coordenador de Município',
  Funcao::COORDENADOR_BAIRRO_ID => 'Coordenador de Bairro',
  Funcao::LIDER_ID => 'Líder',
  Funcao::APOIADOR_ID => 'Apoiador'
}

funcoes.each do |id, nome|
  f = Funcao.find_or_initialize_by(id: id)
  f.name = nome
  f.save!
end
puts "Funções criadas."

# 2. Dados de Municípios, Regiões e Bairros
municipios_data = {
  'Macapá' => {
    'Norte' => [
      'Açaí', 'Pantanal', 'Renascer', 'Ipê', 'Infraero', 'Jardim Felicidade',
      'Novo Horizonte', 'Pacoval', 'Brasil Novo', 'Curiaú', 'Boné Azul',
      'Infraero II', 'Loteamento Açaí', 'São Lázaro', 'Laguinho', 'Jesus de Nazaré', 'Perpétuo Socorro', 'Trem', 'Cidade Nova'
    ],
    'Sul' => [
      'Jardim Marco Zero', 'Bioparque', 'Fazendinha', 'Congós', 'Buritizal',
      'Beirol', 'Santa Rita', 'Muca', 'Universidade', 'Novo Buritizal',
      'Araxá', 'Jardim Equatorial', 'Julião Ramos', 'São José'
    ],
    'Oeste' => [
      'Coração', 'Lagoa Azul', 'Marabaixo', 'Goiabal', 'Cabralzinho', 'Alvorada'
    ],
    'Centro' => [ 'Central' ]
  },
  'Santana' => {
    'Centro' => [
      'Central', 'Comercial', 'Daniel', 'Distrito Industrial', 'Elesbão',
      'Fé em Deus', 'Fonte Nova', 'Fortaleza', 'Hospitalidade', 'Ilha de Santana',
      'Nova Brasília', 'Novo Horizonte', 'Paraíso', 'Provedor', 'Provedor I',
      'Remédios', 'Vila Amazonas'
    ]
  },
  'Laranjal do Jari' => { 'Centro' => [ 'Agreste', 'Centro', 'Malvina' ] },
  'Oiapoque' => { 'Centro' => [ 'Centro' ] },
  'Mazagão' => { 'Centro' => [ 'Centro' ] },
  'Porto Grande' => { 'Centro' => [ 'Centro' ] },
  'Serra do Navio' => { 'Centro' => [ 'Centro' ] },
  'Pedra Branca do Amaparí' => { 'Centro' => [ 'Centro' ] },
  'Calçoene' => { 'Centro' => [ 'Centro' ] },
  'Ferreira Gomes' => { 'Centro' => [ 'Centro' ] },
  'Cutias' => { 'Centro' => [ 'Centro' ] },
  'Pracuúba' => { 'Centro' => [ 'Centro' ] },
  'Itaubal' => { 'Centro' => [ 'Centro' ] },
  'Amapá' => { 'Centro' => [ 'Centro' ] }
}

municipios_data.each do |nome_municipio, regioes|
  municipio = Municipio.find_or_create_by!(name: nome_municipio)

  regioes.each do |nome_regiao, bairros|
    regiao = Regiao.find_or_create_by!(name: nome_regiao, municipio: municipio)

    bairros.each do |nome_bairro|
      Bairro.find_or_create_by!(name: nome_bairro, regiao: regiao)
    end
  end
end
puts "Municípios, Regiões e Bairros criados."

# 3. Criar Apoiador Padrão (Isaac Guerra)
funcao_candidato = Funcao.find(Funcao::CANDIDATO_ID)
municipio_macapa = Municipio.find_by(name: 'Macapá')
regiao_centro = Regiao.find_by(name: 'Centro', municipio: municipio_macapa)
bairro_central = Bairro.find_by(name: 'Central', regiao: regiao_centro)

if funcao_candidato && municipio_macapa && regiao_centro && bairro_central
  apoiador = Apoiador.find_or_create_by!(whatsapp: '5596984102020') do |a|
    a.name = 'Ivone Chagas'
    a.funcao = funcao_candidato
    a.municipio = municipio_macapa
    a.regiao = regiao_centro
    a.bairro = bairro_central
    a.email = 'ivone@ivonechagas.com.br'
    a.projeto = projeto
  end
  puts "Apoiador padrão criado: #{apoiador.name} (#{apoiador.email})"
else
  puts "Erro: Não foi possível encontrar os dados necessários para criar o apoiador padrão."
end

# 3. Criar Apoiador Padrão (Isaac Guerra)
funcao_candidato = Funcao.find(Funcao::COORDENADOR_GERAL_ID)
municipio_macapa = Municipio.find_by(name: 'Macapá')
regiao_centro = Regiao.find_by(name: 'Norte', municipio: municipio_macapa)
bairro_central = Bairro.find_by(name: 'Jesus de Nazaré', regiao: regiao_centro)

if funcao_candidato && municipio_macapa && regiao_centro && bairro_central
  apoiador = Apoiador.find_or_create_by!(whatsapp: '5596984094117') do |a|
    a.name = 'Isaac Guerra'
    a.funcao = funcao_candidato
    a.municipio = municipio_macapa
    a.regiao = regiao_centro
    a.bairro = bairro_central
    a.email = 'isaac@appivone.com'
    a.projeto = projeto
  end
  puts "Apoiador Coordenador Geral criado: #{apoiador.name} (#{apoiador.email})"
else
  puts "Erro: Não foi possível encontrar os dados necessários para criar o apoiador padrão."
end

# Gamification Seeds
puts "Populando dados de Gamificação..."

# Action Weights
weights = {
  "convite_sent" => { points: 2, description: "Envio de convite" },
  "convite_accepted" => { points: 10, description: "Convite aceito" },
  "visit_created" => { points: 15, description: "Visita realizada" },
  "comunicado_received" => { points: 1, description: "Recebimento de comunicado" },
  "comunicado_engaged" => { points: 5, description: "Engajamento em comunicado" },
  "event_participation" => { points: 8, description: "Participação em evento" },
  "daily_login" => { points: 1, description: "Login diário" },
  "chatbot_access" => { points: 1, description: "Acesso ao Chatbot" },
  "chatbot_view_events" => { points: 2, description: "Ver Agenda no Chatbot" },
  "chatbot_view_visits" => { points: 2, description: "Ver Visitas no Chatbot" },
  "chatbot_about" => { points: 5, description: "Ler Sobre o Candidato" }
}

weights.each do |action_type, data|
  Gamification::ActionWeight.find_or_create_by!(action_type: action_type) do |w|
    w.points = data[:points]
    w.description = data[:description]
    w.projeto_id = projeto.id
  end
end

# Levels
levels = [ 0, 100, 300, 700, 1500, 3000, 6000, 12000, 25000, 50000 ]

levels.each_with_index do |threshold, index|
  level_number = index + 1
  Gamification::Level.find_or_create_by!(level: level_number) do |l|
    l.experience_threshold = threshold
    l.projeto_id = projeto.id
  end
end

puts "Dados de Gamificação populados com sucesso!"

puts "Seed concluído!"
