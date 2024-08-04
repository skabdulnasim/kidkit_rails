class VideoProcessingJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find_by(id: video_id)

    if video
      begin
        video.process_video
      rescue => e
        Rails.logger.error("Error processing video ID #{video_id}: #{e.message}")
      end
    else
      Rails.logger.error("Video ID: #{video_id} not found for processing.")
    end
  end
end
