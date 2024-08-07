class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_video

  def index
    comments = @video.comments.includes(:user)
    render json: comments.as_json(include: { user: { only: [:id, :username] } })
  end

  def create
    comment = @video.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment.as_json(include: { user: { only: [:id, :username] } })
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @video.comments.find(params[:id])
    if comment.user == current_user || current_user.admin?
      comment.destroy
      render json: { message: 'Comment deleted' }
    else
      render json: { message: 'Unauthorized' }, status: :forbidden
    end
  end

  private

  def find_video
    @video = Video.find(params[:video_id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Video not found' }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
