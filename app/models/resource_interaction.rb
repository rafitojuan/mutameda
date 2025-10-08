class ResourceInteraction < ApplicationRecord
  belongs_to :user
  belongs_to :resource

  validates :interaction_type, presence: true, inclusion: { 
    in: %w[view like bookmark share] 
  }
  validates :user_id, uniqueness: { scope: [:resource_id, :interaction_type] }

  scope :views, -> { where(interaction_type: 'view') }
  scope :likes, -> { where(interaction_type: 'like') }
  scope :bookmarks, -> { where(interaction_type: 'bookmark') }
  scope :shares, -> { where(interaction_type: 'share') }

  INTERACTION_TYPES = {
    'view' => 'Viewed',
    'like' => 'Liked',
    'bookmark' => 'Bookmarked',
    'share' => 'Shared'
  }.freeze

  def interaction_display
    INTERACTION_TYPES[interaction_type] || interaction_type.humanize
  end

  def self.record_interaction(user, resource, type)
    return false unless INTERACTION_TYPES.key?(type)
    
    interaction = find_or_initialize_by(
      user: user,
      resource: resource,
      interaction_type: type
    )
    
    if interaction.persisted?
      interaction.touch
    else
      interaction.save
    end
    
    interaction
  end

  def self.remove_interaction(user, resource, type)
    interaction = find_by(
      user: user,
      resource: resource,
      interaction_type: type
    )
    
    interaction&.destroy
  end

  def self.toggle_interaction(user, resource, type)
    interaction = find_by(
      user: user,
      resource: resource,
      interaction_type: type
    )
    
    if interaction
      interaction.destroy
      false
    else
      record_interaction(user, resource, type)
      true
    end
  end
end