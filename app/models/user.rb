class User < ApplicationRecord

  devise :database_authenticatable, :registerable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  has_many :videos, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true
  validates :password, presence: true, length: { minimum: 6 }

  def generate_jwt
    JWT.encode({ id: id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.devise[:jwt_secret_key])
  end
end
