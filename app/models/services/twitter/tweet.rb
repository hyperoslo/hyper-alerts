class Services::Twitter::Tweet
  include Mongoid::Document

  # A number describing the Twitter ID of the tweet
  field :twitter_id

  # A string describing the message of the post.
  field :text, type: String

  # A time describing when the post was created on Twitter
  field :created_at, type: Time

  embedded_in :twitter_trackable, polymorphic: true

  embeds_one :author, as: :authorable, class_name: "Services::Twitter::User"

  validates :twitter_id, presence: true
  validates :text, presence: true
  validates :author, presence: true

  def url
    "https://twitter.com/#{author.screen_name}/status/#{twitter_id}"
  end
end
