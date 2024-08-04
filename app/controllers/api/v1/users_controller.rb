class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :login]

  # POST /api/v1/users
  # Sign-up action
  def create
    user = User.new(user_params)
    if user.save
      render json: { message: 'User created successfully' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/users/login
  # Sign-in action
  def login
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      token = user.generate_jwt
      render json: { token: token, username: user.username }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end
end
