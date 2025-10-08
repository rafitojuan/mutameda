class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if user_signed_in?
      @recent_entries = current_user.recent_mood_entries(7)
      @average_mood = current_user.average_mood(30.days)
      @mood_trend = current_user.mood_trend(30.days)
      @wellness_score = calculate_wellness_score
      @mood_distribution = mood_distribution_data
      @recent_triggers = recent_triggers_data
      @streak_count = calculate_streak
      render :dashboard
    else
      render :landing
    end
  end

  private

  def calculate_wellness_score
    recent_entries = current_user.mood_entries.where(logged_at: 7.days.ago..Time.current)
    return 0 if recent_entries.empty?

    scores = recent_entries.map(&:overall_wellness_score).compact
    return 0 if scores.empty?

    (scores.sum / scores.length).round(1)
  end

  def mood_distribution_data
    entries = current_user.mood_entries.where(logged_at: 30.days.ago..Time.current)
    
    distribution = {
      'Excellent (9-10)' => 0,
      'Good (7-8)' => 0,
      'Moderate (5-6)' => 0,
      'Low (3-4)' => 0,
      'Very Low (1-2)' => 0
    }

    entries.each do |entry|
      case entry.mood_level
      when 9..10
        distribution['Excellent (9-10)'] += 1
      when 7..8
        distribution['Good (7-8)'] += 1
      when 5..6
        distribution['Moderate (5-6)'] += 1
      when 3..4
        distribution['Low (3-4)'] += 1
      when 1..2
        distribution['Very Low (1-2)'] += 1
      end
    end

    distribution
  end

  def recent_triggers_data
    trigger_counts = {}
    
    current_user.mood_entries
                .joins(:triggers)
                .where(logged_at: 30.days.ago..Time.current)
                .group('triggers.name')
                .count
                .sort_by { |_, count| -count }
                .first(5)
                .each { |name, count| trigger_counts[name] = count }

    trigger_counts
  end

  def calculate_streak
    entries = current_user.mood_entries.order(logged_at: :desc)
    return 0 if entries.empty?

    streak = 0
    current_date = Date.current

    entries.each do |entry|
      entry_date = entry.logged_at.to_date
      
      if entry_date == current_date
        streak += 1
        current_date -= 1.day
      elsif entry_date == current_date + 1.day
        current_date = entry_date
        streak += 1
        current_date -= 1.day
      else
        break
      end
    end

    streak
  end
end