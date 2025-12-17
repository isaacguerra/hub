module Gamification
  class WeeklyWinner < ApplicationRecord
  include ProjectScoped
  acts_as_tenant :projeto
  belongs_to :projeto, optional: true
  belongs_to :apoiador

    validates :week_start_date, presence: true
    validates :week_end_date, presence: true
    validates :points_total, presence: true

    scope :current_week, -> { where(week_start_date: Time.current.beginning_of_week.to_date) }
  end
end
