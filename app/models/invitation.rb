class Invitation
  include Mongoid::Document

  # A String describing the invitation key.
  field :key, type: String

  validates :key, presence: true, uniqueness: true

  belongs_to :user

  # Sign the key
  def sign
    Digest::MD5.hexdigest key + HyperAlerts::Application.config.secret
  end

  alias :signature :sign
end
