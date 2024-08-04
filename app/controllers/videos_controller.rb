class VideosController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  # GET /videos
  def index
    page = params[:page] || 1
    per_page = params[:count] || 3
  
    @videos = Video.processed_videos
                   .includes(:user)
                   .order(created_at: :desc)
                   .page(page)
                   .per(per_page)
  
    render json: {
      videos: ActiveModel::SerializableResource.new(@videos, each_serializer: VideoSerializer),
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
    @video = Video.find(params[:id])
    render json: @video, serializer: VideoSerializer
  end

  private

  # Strong Parameters
  def video_params
    params.require(:video).permit(:title, :description, :video_file)
  end
end
