json.extract! comunicado, :id, :titulo, :conteudo, :data_envio, :tipo, :created_at, :updated_at
json.url comunicado_url(comunicado, format: :json)
