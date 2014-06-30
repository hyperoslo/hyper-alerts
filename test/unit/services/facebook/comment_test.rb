require 'test_helper'

class Services::Facebook::CommentTest < ActiveSupport::TestCase
  test "should replace comments without a message" do
    page    = create :facebook_page
    post    = create :facebook_post, page: page
    comment = build :facebook_comment, commentable: post, message: ""

    comment.save!

    assert_match "This comment has an attachment", comment.message
  end
end
