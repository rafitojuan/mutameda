class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :like, :bookmark, :view]

  def index
    @resources = Resource.published.includes(:resource_interactions)
    @resources = filter_resources(@resources)
    @resources = @resources.order(created_at: :desc).page(params[:page])
    
    @categories = Resource::CATEGORIES
    @resource_types = Resource::RESOURCE_TYPES
    @popular_resources = Resource.popular(5)
  end

  def show
    ResourceInteraction.record_interaction(current_user, @resource, 'view')
    @related_resources = Resource.published
                                .where(category: @resource.category)
                                .where.not(id: @resource.id)
                                .limit(3)
    @user_interactions = current_user.resource_interactions
                                   .where(resource: @resource)
                                   .index_by(&:interaction_type)
  end

  def like
    toggled = ResourceInteraction.toggle_interaction(current_user, @resource, 'like')
    
    json_response({
      liked: toggled,
      like_count: @resource.like_count,
      message: toggled ? 'Resource liked!' : 'Like removed'
    })
  end

  def bookmark
    toggled = ResourceInteraction.toggle_interaction(current_user, @resource, 'bookmark')
    
    json_response({
      bookmarked: toggled,
      bookmark_count: @resource.bookmark_count,
      message: toggled ? 'Resource bookmarked!' : 'Bookmark removed'
    })
  end

  def view
    ResourceInteraction.record_interaction(current_user, @resource, 'view')
    json_response({ status: 'viewed' })
  end

  def bookmarked
    @bookmarked_resources = current_user.resource_interactions
                                      .includes(:resource)
                                      .where(interaction_type: 'bookmark')
                                      .order(created_at: :desc)
                                      .page(params[:page])
                                      .map(&:resource)
  end

  private

  def set_resource
    @resource = Resource.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found
  end

  def filter_resources(resources)
    resources = resources.by_category(params[:category]) if params[:category].present?
    resources = resources.by_type(params[:resource_type]) if params[:resource_type].present?
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      resources = resources.where(
        'title ILIKE ? OR content ILIKE ?', 
        search_term, search_term
      )
    end

    resources
  end
end