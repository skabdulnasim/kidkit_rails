class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  include Devise::Controllers::Helpers

  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
  
    if token.present?
      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.devise[:jwt_secret_key], true, { algorithm: 'HS256' })
     
        payload = decoded_token.first
        @current_user = User.find_by(id: payload['id'])
      
        if JwtBlacklist.exists?(jti: token)
          render json: { error: 'Token revoked' }, status: :unauthorized
        end
  
        render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
      rescue JWT::ExpiredSignature
        render json: { error: 'Token expired' }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token missing' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
