class MoodEntry < ApplicationRecord
  belongs_to :user
  has_many :mood_triggers, dependent: :destroy
  has_many :triggers, through: :mood_triggers

  before_validation :set_logged_at, on: :create

  validates :mood_level, presence: true, inclusion: { in: 1..10 }
  validates :energy_level, inclusion: { in: 1..10 }, allow_nil: true
  validates :sleep_quality, inclusion: { in: 1..10 }, allow_nil: true
  validates :anxiety_level, inclusion: { in: 1..10 }, allow_nil: true
  validates :stress_level, inclusion: { in: 1..10 }, allow_nil: true
  validates :logged_at, presence: true
  validates :notes, length: { maximum: 1000 }

  private

  def set_logged_at
    self.logged_at ||= Time.current
  end

  scope :recent, -> { order(logged_at: :desc) }
  scope :for_period, ->(start_date, end_date) { where(logged_at: start_date..end_date) }
  scope :with_mood_range, ->(min, max) { where(mood_level: min..max) }

  def mood_description
    case mood_level
    when 1..2
      'Very Low'
    when 3..4
      'Low'
    when 5..6
      'Moderate'
    when 7..8
      'Good'
    when 9..10
      'Excellent'
    end
  end

  def energy_description
    return 'Not recorded' unless energy_level
    
    case energy_level
    when 1..2
      'Very Low'
    when 3..4
      'Low'
    when 5..6
      'Moderate'
    when 7..8
      'High'
    when 9..10
      'Very High'
    end
  end

  def overall_wellness_score
    scores = [mood_level, energy_level, sleep_quality].compact
    anxiety_stress = [anxiety_level, stress_level].compact.map { |score| 11 - score }
    
    all_scores = scores + anxiety_stress
    return 0 if all_scores.empty?
    
    (all_scores.sum.to_f / all_scores.length).round(1)
  end

  def has_concerning_levels?
    mood_level <= 3 || anxiety_level.to_i >= 8 || stress_level.to_i >= 8
  end

  def trigger_names
    triggers.pluck(:name)
  end
end