class Gamification::ApoiadorBadge < ApplicationRecord
  acts_as_tenant :projeto
  belongs_to :apoiador
  belongs_to :badge, class_name: "Gamification::Badge"

  validates :apoiador_id, uniqueness: { scope: :badge_id }
end
