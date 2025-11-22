puts "ENV['REDIS_URL']: #{ENV['REDIS_URL']}"

begin
  puts "Testing Redis Connection..."
  clients_received = Mensageria::RedisClient.publish('mensageria_logs', { test: 'message', timestamp: Time.now.to_s }.to_json)
  puts "Message published to 'mensageria_logs'. Clients received: #{clients_received}"

  puts "\nTesting Full Authentication Flow..."
  apoiador = Apoiador.first
  if apoiador
    puts "Found Apoiador: #{apoiador.name}"
    apoiador.update(verification_code: '123456')

    puts "Calling Mensageria::Notificacoes::Autenticacao.enviar_codigo..."
    Mensageria::Notificacoes::Autenticacao.enviar_codigo(apoiador)
    puts "Method called. Check Redis for the message."
  else
    puts "No Apoiador found to test."
  end

rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace
end
