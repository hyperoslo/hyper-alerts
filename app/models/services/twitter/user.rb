class Services::Twitter::User
  include Mongoid::Document

  # A number describing the Twitter ID of the user
  field :twitter_id

  # A string describing the Twitter user's name.
  field :name, type: String

  # A string describing the url for the Twitter user's profile image.
  field :picture_url, type: String

  # A string describing the Twitter users's screen name
  field :screen_name, type: String

  embedded_in :authorable, polymorphic: true

  validates :twitter_id, presence: true
  validates :screen_name, presence: true
end
