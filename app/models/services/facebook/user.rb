class Services::Facebook::User
  include Mongoid::Document

  # A String describing the Facebook user's name.
  field :name, type: String

  embedded_in :authorable, polymorphic: true

  # Returns a String describing the URL to the user's profile.
  def profile_url
    "https://facebook.com/#{id}"
  end

  # Returns a String describing the URL to the user's picture.
  def picture_url
    "https://graph.facebook.com/#{id}/picture"
  end
end
