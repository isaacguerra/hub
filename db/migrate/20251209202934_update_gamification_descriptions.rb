class UpdateGamificationDescriptions < ActiveRecord::Migration[8.1]
  def up
    descriptions = {
      "convite_sent" => "Envio de Convite",
      "convite_accepted" => "Convite Aceito",
      "visit_created" => "Visita Realizada",
      "comunicado_received" => "Recebimento de Comunicado",
      "comunicado_engaged" => "Engajamento em Comunicado",
      "event_participation" => "Participação em Evento",
      "daily_login" => "Login Diário"
    }

    descriptions.each do |action_type, description|
      Gamification::ActionWeight.find_by(action_type: action_type)&.update(description: description)
    end
  end

  def down
    # No need to revert descriptions
  end
end
