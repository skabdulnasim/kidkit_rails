class Video < ApplicationRecord
  belongs_to :user
  has_one_attached :video_file

  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :video_tags, dependent: :destroy
  has_many :tags, through: :video_tags

  # Ensure that the processed column is available
  validates :processed, inclusion: { in: [true, false] }
  validates :title, presence: true
  validate :validate_video_file

  # Callbacks
  after_create :enqueue_processing_job

  # Scopes
  scope :processed_videos, -> { where(processed: true) }
  scope :unprocessed_videos, -> { where(processed: false) }

  def likes_count
    likes.where(:state=>"like").count
  end

  def unlikes_count
    likes.where(:state=>"unlike").count
  end

  def is_liked_by_user?(user)
    likes.where(:state=>"like").exists?(user: user)
  end

  def is_unliked_by_user?(user)
    likes.where(:state=>"unlike").exists?(user: user)
  end

  # Methods

  # Video URL for JSON Response
  def video_url
    if video_file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(video_file, host: Rails.application.config.default_host)
    else
      nil
    end
  end

  # Enqueue the processing job after creation
  def enqueue_processing_job
    VideoProcessingJob.perform_later(self.id)
  end

  # Method to process video using FFmpeg
  def process_video
    return unless video_file.attached?

    # Open the attached video file
    video_file.open do |file|
      processed_video_path = Rails.root.join("tmp/processed_#{id}.mp4")

      # Call FFmpeg to process the video
      ffmpeg_command = "ffmpeg -i #{Shellwords.escape(file.path)} -vf scale=720:-1 #{Shellwords.escape(processed_video_path)}"
      system(ffmpeg_command)

      # Re-attach the processed video
      video_file.purge # Remove the original video file
      video_file.attach(io: File.open(processed_video_path), filename: "processed_#{id}.mp4", content_type: 'video/mp4')

      # Clean up the temporary file
      File.delete(processed_video_path) if File.exist?(processed_video_path)

      # Mark video as processed
      mark_as_processed
    end
  rescue => e
    Rails.logger.error("Failed to process video: #{e.message}")
    false
  end

  # Method to mark video as processed
  def mark_as_processed
    update(processed: true)
  end

  # Ensure FFmpeg is installed and executable
  def ffmpeg_installed?
    system('ffmpeg -version > /dev/null 2>&1')
  end

  private

  # Validate video file type
  def validate_video_file
    if video_file.attached? && !video_file.content_type.in?(%w[video/mp4 video/mpeg video/avi])
      errors.add(:video_file, 'must be an MP4, MPEG, or AVI file')
    end
  end
end
