class Services::Facebook::Post
  include Mongoid::Document

  include Services::Facebook::Concerns::Commentable

  # A String describing the message of the post.
  field :message, type: String

  # A String describing the URL to the picture of the post.
  field :picture, type: String

  # A String describing the name of the attachment of the post.
  field :name, type: String

  # A String describing the caption to the attachment of the post.
  field :caption, type: String

  # A String describing the attachment of the post.
  field :description, type: String

  # A String describing the URL to the icon of the post.
  field :icon, type: String

  # A Time describing when the post was created on Facebook.
  field :created_at, type: Time

  # A Time describing when the post was updated on Facebook.
  field :updated_at, type: Time

  embedded_in :page

  embeds_one :author, as: :authorable, class_name: "Services::Facebook::User"

  validates :author, presence: true

  # Find comment replies.
  #
  # Returns an Array of Services::Facebook::Comment instances.
  def replies
    comments.map { |comment| comment.comments }.flatten
  end

  def url
    page_id, post_id = id.to_s.split "_"
    "http://facebook.com/permalink.php?story_fbid=#{post_id}&id=#{page_id}"
  end
end
