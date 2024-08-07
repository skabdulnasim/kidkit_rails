class VideoSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :video_url, :created_at, :processed, :is_liked, :is_unliked, :likes_count, :unlikes_count

  belongs_to :user, serializer: UserSerializer
  has_many :tags, serializer: TagSerializer

  # Method to fetch video URL safely
  def video_url
    object.video_url
  end

  def is_liked
    scope && object.is_liked_by_user?(scope)
  end

  def is_unliked
    scope && object.is_unliked_by_user?(scope)
  end
  
  def likes_count
    object.likes_count
  end

  def unlikes_count
    object.unlikes_count
  end

  def thumbnail_url
    # Use Active Storage or Paperclip to get the image URL
    Rails.application.routes.url_helpers.rails_blob_url(object.thumbnail_image, only_path: true) if object.thumbnail_image.attached?
  end
end
