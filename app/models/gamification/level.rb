class Gamification::Level < ApplicationRecord
  acts_as_tenant :projeto
  validates :level, presence: true, uniqueness: true
  validates :experience_threshold, numericality: { greater_than_or_equal_to: 0 }

  after_commit :clear_cache

  private

  def clear_cache
    Rails.cache.delete("gamification_levels_map")
  end
end
