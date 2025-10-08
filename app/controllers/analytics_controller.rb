class AnalyticsController < ApplicationController
  def index
    @period = params[:period] || '30days'
    @date_range = get_date_range(@period)
    
    @mood_trends_data = mood_trends_data
    @trigger_analysis_data = trigger_analysis_data
    @wellness_metrics = wellness_metrics
    @correlation_data = correlation_analysis
  end

  def mood_trends
    period = params[:period] || '30days'
    date_range = get_date_range(period)
    
    trends = current_user.mood_entries
                        .where(logged_at: date_range)
                        .group_by_day(:logged_at)
                        .average(:mood_level)
    
    json_response({
      labels: trends.keys.map { |date| date.strftime('%m/%d') },
      data: trends.values.map { |avg| avg&.round(1) || 0 }
    })
  end

  def trigger_analysis
    period = params[:period] || '30days'
    date_range = get_date_range(period)
    
    trigger_data = current_user.mood_entries
                              .joins(:triggers)
                              .where(logged_at: date_range)
                              .group('triggers.name')
                              .group('triggers.category')
                              .average(:mood_level)
    
    formatted_data = trigger_data.map do |(name, category), avg_mood|
      {
        name: name,
        category: category,
        average_mood: avg_mood.round(1),
        count: current_user.mood_entries
                          .joins(:triggers)
                          .where(logged_at: date_range, triggers: { name: name })
                          .count
      }
    end

    json_response(formatted_data.sort_by { |item| -item[:count] })
  end

  def wellness_report
    period = params[:period] || '30days'
    date_range = get_date_range(period)
    
    entries = current_user.mood_entries.where(logged_at: date_range)
    
    report = {
      total_entries: entries.count,
      average_mood: entries.average(:mood_level)&.round(1) || 0,
      average_energy: entries.average(:energy_level)&.round(1) || 0,
      average_sleep: entries.average(:sleep_quality)&.round(1) || 0,
      average_anxiety: entries.average(:anxiety_level)&.round(1) || 0,
      average_stress: entries.average(:stress_level)&.round(1) || 0,
      concerning_days: entries.where('mood_level <= ? OR anxiety_level >= ? OR stress_level >= ?', 3, 8, 8).count,
      good_days: entries.where(mood_level: 7..10).count,
      most_common_triggers: most_common_triggers(date_range),
      mood_stability: calculate_mood_stability(entries)
    }

    json_response(report)
  end

  private

  def get_date_range(period)
    case period
    when '7days'
      7.days.ago..Time.current
    when '30days'
      30.days.ago..Time.current
    when '90days'
      90.days.ago..Time.current
    when '1year'
      1.year.ago..Time.current
    else
      30.days.ago..Time.current
    end
  end

  def mood_trends_data
    entries = current_user.mood_entries.where(logged_at: @date_range)
    
    daily_moods = entries.group_by_day(:logged_at).average(:mood_level)
    
    {
      labels: daily_moods.keys.map { |date| date.strftime('%m/%d') },
      mood_data: daily_moods.values.map { |avg| avg&.round(1) || 0 },
      energy_data: entries.group_by_day(:logged_at).average(:energy_level).values.map { |avg| avg&.round(1) || 0 },
      sleep_data: entries.group_by_day(:logged_at).average(:sleep_quality).values.map { |avg| avg&.round(1) || 0 }
    }
  end

  def trigger_analysis_data
    trigger_counts = current_user.mood_entries
                                .joins(:triggers)
                                .where(logged_at: @date_range)
                                .group('triggers.name', 'triggers.category', 'triggers.color_code')
                                .count
                                .sort_by { |_, count| -count }
                                .first(10)

    {
      labels: trigger_counts.map { |(name, _, _), _| name },
      data: trigger_counts.map { |_, count| count },
      colors: trigger_counts.map { |(_, _, color), _| color }
    }
  end

  def wellness_metrics
    entries = current_user.mood_entries.where(logged_at: @date_range)
    
    {
      total_entries: entries.count,
      average_mood: entries.average(:mood_level)&.round(1) || 0,
      mood_trend: current_user.mood_trend(@date_range.end - @date_range.begin),
      concerning_days: entries.where('mood_level <= ? OR anxiety_level >= ? OR stress_level >= ?', 3, 8, 8).count,
      good_days: entries.where(mood_level: 7..10).count,
      streak: calculate_current_streak
    }
  end

  def correlation_analysis
    entries = current_user.mood_entries.where(logged_at: @date_range)
    
    {
      mood_energy: calculate_correlation(entries, :mood_level, :energy_level),
      mood_sleep: calculate_correlation(entries, :mood_level, :sleep_quality),
      mood_anxiety: calculate_correlation(entries, :mood_level, :anxiety_level),
      mood_stress: calculate_correlation(entries, :mood_level, :stress_level)
    }
  end

  def calculate_correlation(entries, field1, field2)
    data = entries.where.not(field1 => nil, field2 => nil)
                 .pluck(field1, field2)
    
    return 0 if data.length < 2
    
    x_values = data.map(&:first)
    y_values = data.map(&:last)
    
    n = data.length
    sum_x = x_values.sum
    sum_y = y_values.sum
    sum_xy = x_values.zip(y_values).map { |x, y| x * y }.sum
    sum_x2 = x_values.map { |x| x * x }.sum
    sum_y2 = y_values.map { |y| y * y }.sum
    
    numerator = n * sum_xy - sum_x * sum_y
    denominator = Math.sqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))
    
    return 0 if denominator == 0
    
    (numerator / denominator).round(3)
  end

  def most_common_triggers(date_range)
    current_user.mood_entries
               .joins(:triggers)
               .where(logged_at: date_range)
               .group('triggers.name')
               .count
               .sort_by { |_, count| -count }
               .first(5)
               .to_h
  end

  def calculate_mood_stability(entries)
    moods = entries.order(:logged_at).pluck(:mood_level)
    return 0 if moods.length < 2
    
    differences = moods.each_cons(2).map { |a, b| (a - b).abs }
    average_difference = differences.sum.to_f / differences.length
    
    case average_difference
    when 0..1
      'Very Stable'
    when 1..2
      'Stable'
    when 2..3
      'Moderate'
    when 3..4
      'Variable'
    else
      'Highly Variable'
    end
  end

  def calculate_current_streak
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