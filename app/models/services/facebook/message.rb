class Services::Facebook::Message
  include Mongoid::Document

  # A String describing the message of the message.
  field :message, type: String

  # A Time describing when the message was created on Facebook.
  field :created_at, type: Time

  embedded_in :page

  embeds_one :author, as: :authorable, class_name: "Services::Facebook::User"

  validates :author, presence: true
end
