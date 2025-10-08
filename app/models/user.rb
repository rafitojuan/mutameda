class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :mood_entries, dependent: :destroy
  has_many :user_settings, dependent: :destroy
  has_many :resource_interactions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, length: { maximum: 100 }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.present? ? full_name : email.split('@').first
  end

  def recent_mood_entries(limit = 7)
    mood_entries.order(logged_at: :desc).limit(limit)
  end

  def average_mood(period = 30.days)
    mood_entries.where(logged_at: period.ago..Time.current)
                .average(:mood_level)&.round(1) || 0
  end

  def mood_trend(period = 30.days)
    entries = mood_entries.where(logged_at: period.ago..Time.current)
                         .order(:logged_at)
    
    return 'stable' if entries.count < 2
    
    first_half = entries.limit(entries.count / 2).average(:mood_level) || 0
    second_half = entries.offset(entries.count / 2).average(:mood_level) || 0
    
    difference = second_half - first_half
    
    if difference > 0.3
      'improving'
    elsif difference < -0.3
      'declining'
    else
      'stable'
    end
  end

  def setting(key)
    user_settings.find_by(setting_key: key)&.setting_value
  end

  def set_setting(key, value)
    setting_record = user_settings.find_or_initialize_by(setting_key: key)
    setting_record.setting_value = value
    setting_record.save
  end
end