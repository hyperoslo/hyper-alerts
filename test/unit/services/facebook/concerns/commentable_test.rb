require 'test_helper'

class Services::Facebook::CommentableTest < ActiveSupport::TestCase
  test "should filter items by administrators" do
    page             = create :facebook_page, facebook_id: "hyper"
    post             = create :facebook_post, page: page
    comment_by_admin = create :facebook_comment, commentable: post
    admin            = create :facebook_user, authorable: comment_by_admin, id: page.facebook_id
    comment_by_fan   = create :facebook_comment, commentable: post
    fan              = create :facebook_user, authorable: comment_by_fan

    assert_equal 1, post.comments.by_administrators.count
    assert_equal [comment_by_admin], post.comments.by_administrators
  end

  test "should filter items by fans" do
    page             = create :facebook_page, facebook_id: "hyper"
    post             = create :facebook_post, page: page
    comment_by_admin = create :facebook_comment, commentable: post
    admin            = create :facebook_user, authorable: comment_by_admin, id: page.facebook_id
    comment_by_fan   = create :facebook_comment, commentable: post
    fan              = create :facebook_user, authorable: comment_by_fan

    assert_equal 1, post.comments.by_fans.count
    assert_equal [comment_by_fan], post.comments.by_fans
  end
end
