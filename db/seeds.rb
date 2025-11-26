puts "Iniciando o seed..."

# 1. Criar Funções
funcoes = [
  'Candidato',
  'Coordenador Geral',
  'Coordenador de Região',
  'Coordenador de Município',
  'Coordenador de Bairro',
  'Líder',
  'Apoiador'
]

funcoes.each do |nome_funcao|
  Funcao.find_or_create_by!(name: nome_funcao)
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
funcao_candidato = Funcao.find_by(name: 'Candidato')
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
  end
  puts "Apoiador padrão criado: #{apoiador.name} (#{apoiador.email})"
else
  puts "Erro: Não foi possível encontrar os dados necessários para criar o apoiador padrão."
end

# 3. Criar Apoiador Padrão (Isaac Guerra)
funcao_candidato = Funcao.find_by(name: 'Coordenador Geral')
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
  end
  puts "Apoiador Coordenador Geral criado: #{apoiador.name} (#{apoiador.email})"
else
  puts "Erro: Não foi possível encontrar os dados necessários para criar o apoiador padrão."
end

puts "Seed concluído!"
