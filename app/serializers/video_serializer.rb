class VideoSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :video_url, :created_at, :processed

  belongs_to :user, serializer: UserSerializer

  # Method to fetch video URL safely
  def video_url
    object.video_url
  end

  def thumbnail_url
    # Use Active Storage or Paperclip to get the image URL
    Rails.application.routes.url_helpers.rails_blob_url(object.thumbnail_image, only_path: true) if object.thumbnail_image.attached?
  end
end
