class VideosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_video, only: [:show]

  # GET /videos
  def index
    page = params[:page] || 1
    per_page = params[:count] || 3
  
    @videos = Video.processed_videos
                   .includes(:user, :tags)
                   .order(created_at: :desc)
                   .page(page)
                   .per(per_page)
  
    render json: {
      videos: ActiveModel::SerializableResource.new(@videos, each_serializer: VideoSerializer, scope: @current_user),
      meta: {
        count: @videos.total_count,
        pages: @videos.total_pages,
        current_page: @videos.current_page,
        next: @videos.next_page,
        prev: @videos.prev_page,
      }
    }
  rescue SystemStackError => e
    logger.error("SystemStackError occurred: #{e.message}")
    render json: { error: "An error occurred while processing your request." }, status: :internal_server_error
  end

  # POST /videos
  def create
    @video = current_user.videos.new(video_params)

    if @video.save
      attach_tags if params[:tags].present?
      render json: @video, serializer: VideoSerializer, status: :created
    else
      render json: @video.errors, status: :unprocessable_entity
    end
  rescue ActiveModel::UnknownAttributeError => e
    logger.error("Unknown attribute error: #{e.message}")
    render json: { error: e.message }, status: :bad_request
  end

  # GET /videos/:id
  def show
    render json: @video, serializer: VideoSerializer
  end

  def like
    @video = Video.find(params[:id])
    like = @video.likes.build(user: current_user, state: 1)

    if like.save
      render json: { message: 'Liked successfully' }, status: :ok
    else
      render json: { error: like.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def unlike
    @video = Video.find(params[:id])
    like = @video.likes.build(user: current_user, state: 0)

    if like.save
      render json: { message: 'Unliked successfully' }, status: :ok
    else
      render json: { error: like.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def like_nutral
    @video = Video.find(params[:id])
    like = @video.likes.find_by(user: current_user)

    if like&.destroy
      render json: { message: 'Like Nutral successfully' }, status: :ok
    else
      render json: { error: 'You have not liked this video' }, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters
  def video_params
    params.require(:video).permit(:title, :description, :video_file)
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def attach_tags
    tag_names = params[:tags].map(&:strip).reject(&:empty?).uniq
    tags = tag_names.map { |name| Tag.find_or_create_by(name: name) }
    @video.tags = tags
  end
end
