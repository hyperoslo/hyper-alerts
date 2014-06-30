require 'test_helper'

class Services::Facebook::PostTest < ActiveSupport::TestCase
  test "should derive its url" do
    page = create :facebook_page
    post = create :facebook_post, page: page, id: "6798562721_10152198748677722"

    assert_equal "http://facebook.com/permalink.php?story_fbid=10152198748677722&id=6798562721", post.url
  end

  test "should find replies" do
    page    = create :facebook_page
    post    = create :facebook_post, page: page
    comment = create :facebook_comment, commentable: post
    reply   = create :facebook_comment, commentable: comment

    assert_equal [reply], post.replies
  end
end
