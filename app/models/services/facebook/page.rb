class Services::Facebook::Page
  include Mongoid::Document
  include Mongoid::Paranoia

  include ::Concerns::Synchronizable
  include ::Concerns::Subscribable

  # A String describing the human-readable name of the page (e.g. "Hyper").
  field :name, type: String

  # A String describing the Facebook ID of the page.
  field :facebook_id, type: String

  # An Integer describing how many people like the page.
  field :likes, type: Integer

  # Mongoid extensions for posts, photos and videos.
  filters = Proc.new do

    # Items created by administrators of the Facebook page.
    def by_administrators
      where "author._id" => @base.facebook_id
    end

    # Items created by fans of the Facebook page.
    def by_fans
      where "author._id" => { "$ne" => @base.facebook_id }
    end
  end

  # A collection of Services::Facebook::Post instances.
  embeds_many :posts, class_name: "Services::Facebook::Post", &filters

  # A collection of Services::Facebook::Photo instances.
  embeds_many :photos, class_name: "Services::Facebook::Photo", &filters

  # A collection of Services::Facebook::Video instances.
  embeds_many :videos, class_name: "Services::Facebook::Video", &filters

  # A collection of Services::Facebook::Message instances.
  embeds_many :messages, class_name: "Services::Facebook::Message", &filters

  # A collection of Services::Benchmark instances.
  has_many :benchmarks, as: :benchmarkable, class_name: "Services::Benchmark"

  validates :name, presence: true
  validates :facebook_id, presence: true, uniqueness: true

  # Destroy the page and notify subscribers that it no longer exists.
  #
  # TODO: Notify subscribers that the page no longer exists.
  def disappear
    destroy
  end

  # Returns a String describing the URL to the picture.
  def picture_url
    "https://graph.facebook.com/#{facebook_id}/picture"
  end

  # Synchronize the page using the given access token.
  #
  # access_token - A String describing an access token.
  # options      - A Hash of options:
  #                :only - Array describing aspects of the page to synchronize.
  def synchronize access_token, options = {}
    defaults = {
      only: [:name, :likes, :posts, :photos, :videos, :messages]
    }

    options = defaults.merge options

    granularity = options[:only]

    cached_adapter = adapter access_token

    self.name   = cached_adapter.name if granularity.include? :name
    self.likes  = cached_adapter.likes if granularity.include? :likes
    self.posts  = cached_adapter.posts if granularity.include? :posts
    self.photos = cached_adapter.photos if granularity.include? :photos
    self.videos = cached_adapter.videos if granularity.include? :videos

    if granularity.include? :messages
      me = FbGraph::User.me access_token

      if page = me.accounts.find { |page| page.identifier == facebook_id }
        self.messages = adapter(page.access_token).messages
      end
    end

    save!

    mark_as_synchronized
  end

  # Return an array of AccessToken instances describing access tokens of users who subscribe to this page.
  def access_tokens
    subscribers.map { |subscriber| subscriber.facebook_access_token }
  end

  # Initialize an adapter with the given access token.
  #
  # access_token - A String describing an access token.
  #
  # Returns an Adapters::Facebook instance.
  def adapter access_token
    Services::Facebook::Adapter.new facebook_id, access_token
  end

  # Query Facebook for the page.
  #
  # Returns a FbGraph::Page instance.
  def graph options = {}
    page = FbGraph::Page.fetch facebook_id
  end

  # Determine whether there's anything new for the given subscription
  #
  # subscription - A Subscription instance.
  #
  # Returns a Boolean.
  def updates_for? subscription
    updates_for(subscription).any? { |kind, new_items| new_items.any? }
  end

  # Determine whether there's anything new for the given subscription
  #
  # subscription - A Subscription instance.
  #
  # Returns a Boolean.
  def updates_for subscription
    scope = subscription.scope

    new_posts    = posts
    new_photos   = photos
    new_videos   = videos
    new_messages = messages

    post_conditions = { "created_at" => { "$gt" => subscription.notified_or_created_at } }

    if scope.include? "administrators"
      post_conditions = { "author._id" => facebook_id }.merge post_conditions
    end

    if scope.include? "fans"
      post_conditions = { "author._id" => { "$ne" => facebook_id } }.merge post_conditions
    end

    if scope.include? "comments"
      comment_conditions = { "comments.created_at" => { "$gt" => subscription.notified_or_created_at } }

      if scope.include? "administrators"
        comment_conditions = { "comments.author._id" => facebook_id }.merge comment_conditions
      end

      if scope.include? "fans"
        comment_conditions = { "comments.author._id" => { "$ne" => facebook_id } }.merge comment_conditions
      end

      new_posts  = new_posts.or post_conditions, comment_conditions
      new_photos = new_photos.or post_conditions, comment_conditions
      new_videos = new_videos.or post_conditions, comment_conditions
    else
      new_posts  = new_posts.where post_conditions
      new_photos = new_photos.where post_conditions
      new_videos = new_videos.where post_conditions
    end

    if scope.include? "messages"
      new_messages = messages.where created_at: { "$gt" => subscription.notified_or_created_at }
    end

    Hash.new.tap do |hash|
      if scope.include? "posts"
        hash[:posts] = new_posts
        hash[:photos] = new_photos
        hash[:videos] = new_videos
      end

      if scope.include? "messages"
        hash[:messages] = new_messages
      end
    end
  end

  def to_s
    name
  end

  # Exception raised for pages that cannot be accessed.
  class Inaccessible < StandardError; end

  # Exception raised for pages that no longer exist on Facebook.
  class Disappeared < StandardError; end
end
