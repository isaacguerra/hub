class Gamification::Challenge < ApplicationRecord
  include ProjectScoped

  belongs_to :projeto, optional: true
  belongs_to :winner, class_name: "Apoiador", optional: true
  has_many :participants, class_name: "Gamification::ChallengeParticipant", dependent: :destroy
  has_many :apoiadores, through: :participants

  validates :title, presence: true
  validates :description, presence: true
  validates :reward, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  # Callbacks
  after_create_commit :notify_creation
  after_update_commit :notify_update

  private

  def notify_creation
    Gamification::NotifyChallengeJob.perform_later(id, :created)
  end

  def notify_update
    # Apenas notifica atualização se campos relevantes mudaram
    if saved_change_to_title? || saved_change_to_description? || saved_change_to_rules?
      Gamification::NotifyChallengeJob.perform_later(id, :updated)
    end
  end
end
