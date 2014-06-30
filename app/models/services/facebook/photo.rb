class Services::Facebook::Photo
  include Mongoid::Document

  include Services::Facebook::Concerns::Commentable

  # A String describing the URL to the image embedded in Facebook.
  field :link, type: String

  # A String describing the URL to the image.
  field :source, type: String

  # A Time instance describing when the photo was created on Facebook.
  field :created_at, type: Time

  # A String describing the photo.
  field :caption, type: String

  validates :link, presence: true
  validates :created_at, presence: true

  embedded_in :page
  embeds_one :author, as: :authorable, class_name: "Services::Facebook::User"
end
