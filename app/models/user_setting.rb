class UserSetting < ApplicationRecord
  belongs_to :user

  validates :setting_key, presence: true, length: { maximum: 100 }
  validates :setting_value, length: { maximum: 500 }
  validates :setting_key, uniqueness: { scope: :user_id }

  VALID_SETTINGS = {
    'theme' => %w[light dark auto],
    'notifications_enabled' => %w[true false],
    'reminder_frequency' => %w[daily weekly never],
    'reminder_time' => nil,
    'privacy_level' => %w[private friends public],
    'data_export_format' => %w[json csv pdf],
    'mood_scale_type' => %w[1-10 1-5 emoji],
    'dashboard_widgets' => nil,
    'analytics_period' => %w[7days 30days 90days 1year],
    'timezone' => nil
  }.freeze

  def self.valid_keys
    VALID_SETTINGS.keys
  end

  def self.valid_values_for(key)
    VALID_SETTINGS[key]
  end

  def valid_value?
    return true unless VALID_SETTINGS.key?(setting_key)
    
    valid_values = VALID_SETTINGS[setting_key]
    return true if valid_values.nil?
    
    valid_values.include?(setting_value)
  end

  def boolean_value
    setting_value == 'true'
  end

  def integer_value
    setting_value.to_i
  end

  def array_value
    return [] unless setting_value
    
    begin
      JSON.parse(setting_value)
    rescue JSON::ParserError
      setting_value.split(',').map(&:strip)
    end
  end
end