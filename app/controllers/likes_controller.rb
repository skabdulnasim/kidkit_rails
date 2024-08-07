class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_video

  def create
    if @video.likes.where(user: current_user).exists?
      render json: { message: 'Already liked' }, status: :unprocessable_entity
    else
      @video.likes.create(user: current_user, state: params[:state])
      render json: { likes_count: @video.likes.count }
    end
  end

  def destroy
    like = @video.likes.find_by(user: current_user)
    if like
      like.destroy
      render json: { likes_count: @video.likes.count }
    else
      render json: { message: 'Not liked yet' }, status: :unprocessable_entity
    end
  end

  private

  def find_video
    @video = Video.find(params[:video_id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Video not found' }, status: :not_found
  end
end
