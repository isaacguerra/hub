# Configuração de pesos e níveis para Gamificação

# Pesos para cada tipo de ação
GAMIFICATION_WEIGHTS = {
  "convite_sent" => 2,
  "convite_accepted" => 10,
  "visit_created" => 15,
  "comunicado_received" => 1,
  "comunicado_engaged" => 5,
  "event_participation" => 8,
  "daily_login" => 1
}.freeze

# Limiares de XP para cada nível
# Level 1: 0-99
# Level 2: 100-299
# Level 3: 300-699
# ...
GAMIFICATION_LEVELS = [0, 100, 300, 700, 1500, 3000, 6000, 12000, 25000, 50000].freeze
