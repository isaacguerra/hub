class Gamification::ActionWeight < ApplicationRecord
  acts_as_tenant :projeto
  validates :action_type, presence: true, uniqueness: true
  validates :points, numericality: { only_integer: true }

  after_commit :clear_cache

  # Constantes para Ações do Chatbot
  CHATBOT_ACCESS = 'chatbot_access'
  CHATBOT_VIEW_EVENTS = 'chatbot_view_events'
  CHATBOT_VIEW_VISITS = 'chatbot_view_visits'
  CHATBOT_ABOUT = 'chatbot_about'

  # Lista de ações que só pontuam uma vez por dia
  DAILY_ACTIONS = [
    'daily_login',
    CHATBOT_ACCESS,
    CHATBOT_VIEW_EVENTS,
    CHATBOT_VIEW_VISITS,
    CHATBOT_ABOUT
  ].freeze

  private

  def clear_cache
    Rails.cache.delete("gamification_weight_#{action_type}")
  end
end
