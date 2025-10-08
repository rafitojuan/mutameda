class TriggersController < ApplicationController
  def index
    @triggers = Trigger.active.order(:category, :name)
    @triggers_by_category = @triggers.group_by(&:category)
    @user_trigger_usage = user_trigger_usage_data
  end

  def show
    @trigger = Trigger.find(params[:id])
    @usage_stats = trigger_usage_stats(@trigger)
    @related_mood_entries = current_user.mood_entries
                                       .joins(:triggers)
                                       .where(triggers: { id: @trigger.id })
                                       .order(logged_at: :desc)
                                       .limit(10)
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found
  end

  private

  def user_trigger_usage_data
    current_user.mood_entries
               .joins(:triggers)
               .group('triggers.id', 'triggers.name', 'triggers.category')
               .count
               .map do |(id, name, category), count|
                 {
                   id: id,
                   name: name,
                   category: category,
                   usage_count: count
                 }
               end
               .sort_by { |item| -item[:usage_count] }
  end

  def trigger_usage_stats(trigger)
    entries_with_trigger = current_user.mood_entries
                                      .joins(:triggers)
                                      .where(triggers: { id: trigger.id })

    {
      total_usage: entries_with_trigger.count,
      average_mood_with_trigger: entries_with_trigger.average(:mood_level)&.round(1) || 0,
      last_used: entries_with_trigger.maximum(:logged_at),
      usage_by_month: entries_with_trigger.group_by_month(:logged_at).count,
      mood_distribution: mood_distribution_for_trigger(entries_with_trigger)
    }
  end

  def mood_distribution_for_trigger(entries)
    distribution = Hash.new(0)
    
    entries.each do |entry|
      case entry.mood_level
      when 1..2
        distribution['Very Low'] += 1
      when 3..4
        distribution['Low'] += 1
      when 5..6
        distribution['Moderate'] += 1
      when 7..8
        distribution['Good'] += 1
      when 9..10
        distribution['Excellent'] += 1
      end
    end

    distribution
  end
end