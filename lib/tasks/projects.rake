namespace :projects do
  desc "Create default projeto and backfill existing records assigning projeto_id"
  task backfill_existing: :environment do
    default = Projeto.find_or_create_by!(slug: "default") do |p|
      p.name = "Default Project"
      p.active = true
    end

    models = %w[Apoiador Evento Convite Visita Comunicado ApoiadoresEvento ComunicadoApoiador Veiculo]

    models.each do |model_name|
      begin
        model = model_name.constantize
      rescue NameError
        puts "Model #{model_name} not found, skipping."
        next
      end

      puts "Backfilling #{model_name}..."
      model.where(projeto_id: nil).in_batches(of: 1000) do |relation|
        relation.update_all(projeto_id: default.id)
      end
    end

    puts "Backfill completed. Default projeto id: #{default.id}"
  end
end
