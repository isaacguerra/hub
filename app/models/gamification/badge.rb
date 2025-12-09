class Gamification::Badge < ApplicationRecord
  has_many :apoiador_badges, class_name: "Gamification::ApoiadorBadge", dependent: :destroy
  has_many :apoiadores, through: :apoiador_badges

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
