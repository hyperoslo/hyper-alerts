class Services::Facebook::Comment
  include Mongoid::Document

  # A string describing the message of the comment.
  field :message, type: String

  # A time describing when the comment was created on Facebook.
  field :created_at, type: Time

  embedded_in :commentable, polymorphic: true

  embeds_one :author, as: :authorable, class_name: "Services::Facebook::User"
  embeds_many :comments, as: :commentable, order: :created_at.asc, class_name: "Services::Facebook::Comment"

  before_validation :replace_message_for_comments_with_attachments

  private

  # Facebook doesn't list attachments for comments in the Graph API yet, so in order
  # to render something a little nicer than a seemingly blank comment we're going to replace
  # with instructions to view the comment on Facebook.
  def replace_message_for_comments_with_attachments
    if message.blank?
      self.message = "This comment has an attachment, but due to limitations in Facebook's API we can't " +
                     "show it to you in the e-mail. Please click 'view on Facebook' to see it."
    end
  end
end
