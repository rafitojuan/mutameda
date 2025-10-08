class MoodTrigger < ApplicationRecord
  belongs_to :mood_entry
  belongs_to :trigger

  validates :mood_entry_id, presence: true
  validates :trigger_id, presence: true
  validates :mood_entry_id, uniqueness: { scope: :trigger_id }
end