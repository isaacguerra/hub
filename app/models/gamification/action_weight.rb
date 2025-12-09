class Gamification::ActionWeight < ApplicationRecord
  validates :action_type, presence: true, uniqueness: true
  validates :points, numericality: { only_integer: true }

  after_commit :clear_cache

  private

  def clear_cache
    Rails.cache.delete("gamification_weight_#{action_type}")
  end
end
