require 'test_helper'

class Services::Facebook::PageTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze
  end

  teardown do
    Timecop.return
  end

  test "should filter items by administrators" do
    page          = create :facebook_page, facebook_id: "hyper"
    post_by_admin = create :facebook_post, page: page
    admin         = create :facebook_user, authorable: post_by_admin, id: page.facebook_id
    post_by_fan   = create :facebook_post, page: page
    fan           = create :facebook_user, authorable: post_by_fan

    assert_equal 1, page.posts.by_administrators.count
    assert_equal [post_by_admin], page.posts.by_administrators
  end

  test "should filter items by fans" do
    page          = create :facebook_page, facebook_id: "hyper"
    post_by_admin = create :facebook_post, page: page
    admin         = create :facebook_user, authorable: post_by_admin, id: page.facebook_id
    post_by_fan   = create :facebook_post, page: page
    fan           = create :facebook_user, authorable: post_by_fan

    assert_equal 1, page.posts.by_fans.count
    assert_equal [post_by_fan], page.posts.by_fans
  end

  test "should determine the URL to its picture" do
    page = create :facebook_page

    assert_equal "https://graph.facebook.com/#{page.facebook_id}/picture", page.picture_url
  end

  test "should disappear" do
    page = create :facebook_page

    page.disappear

    assert_equal true, page.destroyed?
  end

  test "should synchronize" do
    user         = create :user
    page         = create :facebook_page_with_posts_and_comments
    access_token = create :facebook_access_token, user: user
    posts        = build_list :facebook_post_with_comments, 5
    photos       = build_list :facebook_photo_with_comments, 5
    videos       = build_list :facebook_video_with_comments, 5
    messages     = build_list :facebook_message, 5

    FbGraph::User.any_instance.stubs(:accounts).returns([stub(identifier: page.facebook_id, access_token: "...")])

    Services::Facebook::Adapter.any_instance.stubs(:query)
    Services::Facebook::Adapter.any_instance.stubs(:likes).returns(100)
    Services::Facebook::Adapter.any_instance.stubs(:name).returns("Hyper Alerts")
    Services::Facebook::Adapter.any_instance.stubs(:posts).returns(posts)
    Services::Facebook::Adapter.any_instance.stubs(:photos).returns(photos)
    Services::Facebook::Adapter.any_instance.stubs(:videos).returns(videos)
    Services::Facebook::Adapter.any_instance.stubs(:messages).returns(messages)

    page.synchronize access_token.token

    assert_equal Time.now, page.synchronized_at

    assert_equal "Hyper Alerts", page.name

    assert_equal 5, page.posts.count
    assert_equal 5, page.posts.first.comments.count

    assert_equal 5, page.photos.count
    assert_equal 5, page.photos.first.comments.count

    assert_equal 5, page.videos.count
    assert_equal 5, page.videos.first.comments.count

    assert_equal 5, page.messages.count

    assert_equal 100, page.likes
  end

  test "should find subscribers' access tokens" do
    page = create :facebook_page
    users = [
      create(:user),
      create(:user)
    ]
    access_tokens = [
      create(:facebook_access_token, user: users.first),
      create(:facebook_access_token, user: users.last)
    ]
    subscriptions = [
      create(:subscription, user: users.first, subscribable: page, frequency: "*/15 * * * *"),
      create(:subscription, user: users.second, subscribable: page, frequency: "0 * * * *")
    ]

    assert_equal access_tokens, page.access_tokens
  end

  test "should determine whether there's something new for a given subscription" do
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, notified_at: 4.days.ago, scope: ["posts", "comments", "messages"]
    posts = [
      create(:facebook_post, page: page, created_at: 7.days.ago, updated_at: 7.days.ago),
      create(:facebook_post, page: page, created_at: 2.days.ago, updated_at: 2.days.ago),
      create(:facebook_post, page: page, created_at: 4.hours.ago, updated_at: 4.hours.ago)
    ]

    assert_equal true, page.updates_for?(subscription)
  end

  test "should determine what's new for a given subscription from anyone with scope posts and comments" do
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, notified_at: 4.days.ago, scope: ["posts", "comments", "anyone"]
    new_post     = create :facebook_post, page: page, created_at: 3.days.ago, updated_at: 7.days.ago
    old_post     = create :facebook_post, page: page, created_at: 7.days.ago, updated_at: 3.days.ago
    new_comment  = create :facebook_comment, commentable: old_post, created_at: 3.days.ago

    updates = page.updates_for subscription

    assert_includes updates[:posts], new_post
    assert_includes updates[:posts], old_post
  end

  test "should determine what's new for a given subscription from administrators with scope posts and comments" do
    page                 = create :facebook_page
    subscription         = create :subscription, subscribable: page, notified_at: 4.days.ago, scope: ["posts", "comments", "administrators"]
    fan                  = build :facebook_user
    admin                = build :facebook_user, id: page.facebook_id
    new_post_by_admin    = create :facebook_post, page: page, created_at: 3.days.ago, updated_at: 7.days.ago, author: admin
    old_post_by_fan      = create :facebook_post, page: page, created_at: 7.days.ago, updated_at: 3.days.ago, author: fan
    new_comment_by_admin = create :facebook_comment, commentable: old_post_by_fan, created_at: 3.days.ago, author: admin

    updates = page.updates_for subscription

    assert_includes updates[:posts], new_post_by_admin
    assert_includes updates[:posts], old_post_by_fan
  end

  test "should determine what's new for a given subscription from anyone with scope posts" do
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, notified_at: 4.days.ago, scope: ["posts", "anyone"]
    new_post     = create :facebook_post, page: page, created_at: 3.days.ago, updated_at: 7.days.ago
    old_post     = create :facebook_post, page: page, created_at: 7.days.ago, updated_at: 3.days.ago
    new_comment  = create :facebook_comment, commentable: old_post, created_at: 3.days.ago

    updates = page.updates_for subscription

    assert_includes updates[:posts], new_post
    refute_includes updates[:posts], old_post
  end

  test "should determine what's new for a given subscription from administrators with scope posts" do
    page              = create :facebook_page
    subscription      = create :subscription, subscribable: page, notified_at: 4.days.ago, scope: ["posts", "anyone", "administrators"]
    fan               = build :facebook_user
    admin             = build :facebook_user, id: page.facebook_id
    new_post_by_admin = create :facebook_post, page: page, created_at: 3.days.ago, updated_at: 3.days.ago, author: admin
    new_post_by_fan   = create :facebook_post, page: page, created_at: 3.days.ago, updated_at: 3.days.ago, author: fan

    updates = page.updates_for subscription

    assert_includes updates[:posts], new_post_by_admin
    refute_includes updates[:posts], new_post_by_fan
  end
end
