class Services::Facebook::Video
  include Mongoid::Document
  
  include Services::Facebook::Concerns::Commentable

  # A String describing the name of the video.
  field :name, type: String

  # A String describing the URL to the thumbnail of the video.
  field :picture, type: String

  # A String describing the URL to the video.
  field :source, type: String

  # A Time instance describing when the video was created on Facebook.
  field :created_at, type: Time

  # A Time instance when the video was updated on Facebook.
  field :updated_at, type: Time

  validates :picture, presence: true
  validates :created_at, presence: true
  validates :updated_at, presence: true

  embedded_in :page
  embeds_one :author, as: :authorable, class_name: "Services::Facebook::User"

  def url
    "https://facebook.com/#{id}"
  end
end
