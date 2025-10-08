class Resource < ApplicationRecord
  has_many :resource_interactions, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  validates :category, presence: true, inclusion: { 
    in: %w[coping_strategies mindfulness crisis_support educational articles exercises tools] 
  }
  validates :resource_type, presence: true, inclusion: { 
    in: %w[article video audio exercise tool link] 
  }
  validates :external_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  scope :published, -> { where(is_published: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_type, ->(type) { where(resource_type: type) }

  CATEGORIES = {
    'coping_strategies' => 'Coping Strategies',
    'mindfulness' => 'Mindfulness & Meditation',
    'crisis_support' => 'Crisis Support',
    'educational' => 'Educational Content',
    'articles' => 'Articles & Guides',
    'exercises' => 'Exercises & Activities',
    'tools' => 'Tools & Assessments'
  }.freeze

  RESOURCE_TYPES = {
    'article' => 'Article',
    'video' => 'Video',
    'audio' => 'Audio',
    'exercise' => 'Exercise',
    'tool' => 'Tool',
    'link' => 'External Link'
  }.freeze

  def category_display
    CATEGORIES[category] || category.humanize
  end

  def type_display
    RESOURCE_TYPES[resource_type] || resource_type.humanize
  end

  def interaction_count(type = nil)
    scope = resource_interactions
    scope = scope.where(interaction_type: type) if type
    scope.count
  end

  def view_count
    interaction_count('view')
  end

  def like_count
    interaction_count('like')
  end

  def bookmark_count
    interaction_count('bookmark')
  end

  def user_interaction(user, type)
    resource_interactions.find_by(user: user, interaction_type: type)
  end

  def liked_by?(user)
    user_interaction(user, 'like').present?
  end

  def bookmarked_by?(user)
    user_interaction(user, 'bookmark').present?
  end

  def viewed_by?(user)
    user_interaction(user, 'view').present?
  end

  def self.popular(limit = 10)
    joins(:resource_interactions)
      .group(:id)
      .order('COUNT(resource_interactions.id) DESC')
      .limit(limit)
  end

  def self.recent(limit = 10)
    published.order(created_at: :desc).limit(limit)
  end
end