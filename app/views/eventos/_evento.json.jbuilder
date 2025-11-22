json.extract! evento, :id, :titulo, :descricao, :data_hora, :local, :coordenador_id, :created_at, :updated_at
json.url evento_url(evento, format: :json)
