class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :profile_picture

  def profile_picture
    "https://lh3.googleusercontent.com/a/ACg8ocLaMSX8xpVfxrK2gFMbEFngVlQozNMnS5cEI9NlseVbugukAUg-=s360-c-no"
  end
end
