class Trigger < ApplicationRecord
  has_many :mood_triggers, dependent: :destroy
  has_many :mood_entries, through: :mood_triggers

  validates :name, presence: true, length: { maximum: 100 }
  validates :category, presence: true, inclusion: { 
    in: %w[work relationships health social environment personal other] 
  }
  validates :color_code, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }

  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category) { where(category: category) }

  CATEGORIES = {
    'work' => 'Work & Career',
    'relationships' => 'Relationships',
    'health' => 'Health & Wellness',
    'social' => 'Social Situations',
    'environment' => 'Environment',
    'personal' => 'Personal Issues',
    'other' => 'Other'
  }.freeze

  def category_display
    CATEGORIES[category] || category.humanize
  end

  def usage_count(user = nil, period = 30.days)
    scope = mood_triggers.joins(:mood_entry)
    scope = scope.where(mood_entries: { user_id: user.id }) if user
    scope = scope.where(mood_entries: { logged_at: period.ago..Time.current })
    scope.count
  end

  def self.most_common(user = nil, limit = 10)
    scope = joins(:mood_triggers).joins(:mood_entries)
    scope = scope.where(mood_entries: { user_id: user.id }) if user
    scope.group(:id)
         .order('COUNT(mood_triggers.id) DESC')
         .limit(limit)
  end

  def self.by_category_with_counts(user = nil)
    scope = active
    scope = scope.joins(:mood_triggers).joins(:mood_entries).where(mood_entries: { user_id: user.id }) if user
    
    scope.group(:category)
         .group(:id)
         .order(:category, :name)
  end
end