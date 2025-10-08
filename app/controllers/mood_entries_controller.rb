class MoodEntriesController < ApplicationController
  before_action :set_mood_entry, only: [:show, :edit, :update, :destroy]

  def index
    @mood_entries = current_user.mood_entries
                               .includes(:triggers)
                               .order(logged_at: :desc)
                               .page(params[:page])
    
    @mood_entries = filter_entries(@mood_entries) if params[:filter].present?
    @average_mood = @mood_entries.average(:mood_level)&.round(1) || 0
  end

  def show
    @related_entries = current_user.mood_entries
                                  .where.not(id: @mood_entry.id)
                                  .where(mood_level: (@mood_entry.mood_level - 1)..(@mood_entry.mood_level + 1))
                                  .limit(3)
  end

  def new
    @mood_entry = current_user.mood_entries.build
    @triggers = Trigger.active.order(:category, :name)
  end

  def create
    @mood_entry = current_user.mood_entries.build(mood_entry_params)
    @mood_entry.logged_at = Time.current

    if @mood_entry.save
      handle_triggers
      redirect_with_notice(mood_entries_path, 'Mood entry created successfully!')
    else
      @triggers = Trigger.active.order(:category, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def quick_entry
    @mood_entry = current_user.mood_entries.build
    @triggers = Trigger.active.limit(10)
    render layout: false
  end

  def create_quick
    @mood_entry = current_user.mood_entries.build(quick_entry_params)
    @mood_entry.logged_at = Time.current

    if @mood_entry.save
      handle_triggers
      json_response({ 
        status: 'success', 
        message: 'Mood logged successfully!',
        mood_level: @mood_entry.mood_level,
        mood_description: @mood_entry.mood_description
      })
    else
      json_response({ 
        status: 'error', 
        errors: @mood_entry.errors.full_messages 
      }, :unprocessable_entity)
    end
  end

  def edit
    @triggers = Trigger.active.order(:category, :name)
  end

  def update
    if @mood_entry.update(mood_entry_params)
      handle_triggers
      redirect_with_notice(mood_entry_path(@mood_entry), 'Mood entry updated successfully!')
    else
      @triggers = Trigger.active.order(:category, :name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @mood_entry.destroy
    redirect_with_notice(mood_entries_path, 'Mood entry deleted successfully!')
  end

  private

  def set_mood_entry
    @mood_entry = current_user.mood_entries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found
  end

  def mood_entry_params
    params.require(:mood_entry).permit(
      :mood_level, :energy_level, :sleep_quality, 
      :anxiety_level, :stress_level, :notes
    )
  end

  def quick_entry_params
    params.require(:mood_entry).permit(:mood_level, :notes, trigger_ids: [])
  end

  def handle_triggers
    return unless params[:mood_entry][:trigger_ids].present?

    trigger_ids = params[:mood_entry][:trigger_ids].reject(&:blank?)
    @mood_entry.trigger_ids = trigger_ids
  end

  def filter_entries(entries)
    case params[:filter]
    when 'low_mood'
      entries.where(mood_level: 1..4)
    when 'high_mood'
      entries.where(mood_level: 7..10)
    when 'concerning'
      entries.where('mood_level <= ? OR anxiety_level >= ? OR stress_level >= ?', 3, 8, 8)
    when 'this_week'
      entries.where(logged_at: 1.week.ago..Time.current)
    when 'this_month'
      entries.where(logged_at: 1.month.ago..Time.current)
    else
      entries
    end
  end
end