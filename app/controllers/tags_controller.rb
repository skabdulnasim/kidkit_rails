class TagsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    tags = Tag.all
    render json: tags
  end

  def create
    tag_names = params[:tags].map(&:strip).reject(&:empty?).uniq

    tags = tag_names.map do |tag_name|
      Tag.find_or_create_by(name: tag_name)
    end

    @video = Video.find(params[:video_id])
    @video.tags = tags

    render json: @video.tags
  end
end
