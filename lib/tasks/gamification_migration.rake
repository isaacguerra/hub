namespace :gamification do
  desc "Migrate gamification constants to database"
  task migrate_constants: :environment do
    # Migrate Weights
    if defined?(GAMIFICATION_WEIGHTS)
      GAMIFICATION_WEIGHTS.each do |action, points|
        Gamification::ActionWeight.find_or_create_by!(action_type: action) do |w|
          w.points = points
          w.description = "Peso inicial migrado de constante"
        end
      end
      puts "Pesos migrados com sucesso!"
    end

    # Migrate Levels
    if defined?(GAMIFICATION_LEVELS)
      GAMIFICATION_LEVELS.each_with_index do |threshold, index|
        level_number = index + 1
        Gamification::Level.find_or_create_by!(level: level_number) do |l|
          l.experience_threshold = threshold
        end
      end
      puts "Níveis migrados com sucesso!"
    end
  end
end
