# app/models/jwt_blacklist.rb
class JwtBlacklist < ApplicationRecord
  def self.blacklisted?(jti)
    exists?(jti: jti)
  end
end
