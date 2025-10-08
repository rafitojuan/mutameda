class Profile::SettingsController < ApplicationController
  def index
    redirect_to profile_settings_path
  end

  def settings
    @user_settings = current_user_settings
    @available_timezones = ActiveSupport::TimeZone.all.map { |tz| [tz.to_s, tz.name] }
  end

  def update_settings
    settings_params.each do |key, value|
      if UserSetting.valid_keys.include?(key)
        set_user_setting(key, value)
      end
    end

    redirect_with_notice(profile_settings_path, 'Settings updated successfully!')
  rescue => e
    redirect_with_alert(profile_settings_path, 'Failed to update settings. Please try again.')
  end

  def privacy
    @privacy_settings = {
      'privacy_level' => user_setting('privacy_level', 'private'),
      'data_sharing' => user_setting('data_sharing', 'false'),
      'analytics_tracking' => user_setting('analytics_tracking', 'true')
    }
  end

  def export_data
    format = params[:format] || user_setting('data_export_format', 'json')
    
    case format
    when 'json'
      export_json_data
    when 'csv'
      export_csv_data
    when 'pdf'
      export_pdf_data
    else
      redirect_with_alert(profile_settings_path, 'Invalid export format.')
    end
  end

  private

  def settings_params
    params.require(:settings).permit(
      :theme, :notifications_enabled, :reminder_frequency, :reminder_time,
      :privacy_level, :data_export_format, :mood_scale_type, :analytics_period,
      :timezone, dashboard_widgets: []
    )
  end

  def export_json_data
    data = {
      user: {
        email: current_user.email,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        created_at: current_user.created_at
      },
      mood_entries: current_user.mood_entries.includes(:triggers).map do |entry|
        {
          mood_level: entry.mood_level,
          energy_level: entry.energy_level,
          sleep_quality: entry.sleep_quality,
          anxiety_level: entry.anxiety_level,
          stress_level: entry.stress_level,
          notes: entry.notes,
          logged_at: entry.logged_at,
          triggers: entry.triggers.pluck(:name)
        }
      end,
      settings: current_user.user_settings.map do |setting|
        {
          key: setting.setting_key,
          value: setting.setting_value
        }
      end,
      resource_interactions: current_user.resource_interactions.includes(:resource).map do |interaction|
        {
          resource_title: interaction.resource.title,
          interaction_type: interaction.interaction_type,
          created_at: interaction.created_at
        }
      end
    }

    send_data data.to_json, 
              filename: "mood_tracker_data_#{Date.current}.json",
              type: 'application/json',
              disposition: 'attachment'
  end

  def export_csv_data
    require 'csv'
    
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Date', 'Mood Level', 'Energy Level', 'Sleep Quality', 'Anxiety Level', 'Stress Level', 'Notes', 'Triggers']
      
      current_user.mood_entries.includes(:triggers).order(:logged_at).each do |entry|
        csv << [
          entry.logged_at.strftime('%Y-%m-%d %H:%M'),
          entry.mood_level,
          entry.energy_level,
          entry.sleep_quality,
          entry.anxiety_level,
          entry.stress_level,
          entry.notes,
          entry.triggers.pluck(:name).join(', ')
        ]
      end
    end

    send_data csv_data,
              filename: "mood_tracker_data_#{Date.current}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  def export_pdf_data
    redirect_with_alert(profile_settings_path, 'PDF export is not yet available. Please use JSON or CSV format.')
  end
end