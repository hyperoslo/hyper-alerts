# encoding: utf-8

require 'test_helper'

class Services::Facebook::AdapterTest < ActiveSupport::TestCase
  test "should raise an error if the page is inaccessible" do
    page         = create :facebook_page
    access_token = create :facebook_access_token

    FbGraph::Page.
      expects(
        :fetch
      ).
      raises(
        FbGraph::InvalidRequest.new "Unsupported get request."
      )

    assert_raises Services::Facebook::Page::Inaccessible do
      Services::Facebook::Adapter.new page.id, access_token.token
    end
  end

  test "should raise an error if the page has been deleted" do
    page         = create :facebook_page
    access_token = create :facebook_access_token

    FbGraph::Page.
      expects(
        :fetch
      ).
      raises(
        FbGraph::NotFound.new "(#803) Some of the aliases you requested do not exist: test"
      )

    assert_raises Services::Facebook::Page::Disappeared do
      Services::Facebook::Adapter.new page.id, access_token.token
    end
  end

  test "should query name" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    assert_equal "Hyper", adapter.name
  end

  test "should query likes" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    assert_equal 874, adapter.likes
  end

  test "should query photos" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    stub_request(
      :get, /graph.facebook.com\/fql.+/
    ).
    to_return(
      fixture "services/facebook/page/photo.txt"
    )

    stub_request(
      :get, /graph.facebook.com\/[0-9_]+\/comments/
    ).
    to_return(
      fixture "services/facebook/page/comments.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    photo = adapter.photos.first

    assert_equal "10152139370017855", photo.id
    assert_match "http://www.facebook.com", photo.link
    assert_match "http://photos-a.ak.fbcdn.net", photo.source
    assert_equal "2014-01-07 12:07:53 UTC", photo.created_at.to_s

    comment = photo.comments.first

    assert_equal "10152139370017855_12233490", comment.id
    assert_equal "Ai ai, nice :D", comment.message
    assert_equal "830195522", comment.author.id
    assert_equal "Kjetil Myhre Berge", comment.author.name
    assert_equal "2014-01-07 12:11:04 UTC", comment.created_at.to_s
  end

  test "should query videos" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    stub_request(
      :get, /graph.facebook.com\/fql.+/
    ).
    to_return(
      fixture "services/facebook/page/video.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    video = adapter.videos.first

    assert_equal "10151322440991566", video.id
    assert_equal "Bademiljø Behind the scenes", video.name
    assert_match "http://vthumb.ak.fbcdn.net", video.picture
    assert_match "http://video.ak.fbcdn.net", video.source
    assert_equal "2013-03-17 08:17:16 UTC", video.created_at.to_s
    assert_equal "2013-03-17 08:17:16 UTC", video.updated_at.to_s

    comment = video.comments.first

    assert_equal "10151322440991566_28426422", comment.id
    assert_match "Herlig karakter det der!", comment.message
    assert_equal "733831006", comment.author.id
    assert_equal "Erlend Greiner", comment.author.name
    assert_equal "2013-03-17 11:01:30 UTC", comment.created_at.to_s
  end

  test "should query the feed" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    stub_request(
      :get, /graph.facebook.com\/fql.+/
    ).
    to_return(
      fixture "services/facebook/page/stream.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    post = adapter.posts.second

    assert_equal "6798562721_1396030160646314", post.id
    assert_equal "http://youtu.be/jPbf1V6qegU", post.message
    assert_match "http://external.ak.fbcdn.net", post.picture
    assert_equal "Peru Moral Police Assault Nightclub Employees", post.name
    assert_equal "Life is hard", post.caption
    assert_match "Local vigilante group", post.description
    assert_equal "100007180296654", post.author.id
    assert_equal "Gani Ganesh", post.author.name
    assert_match "http://static.ak.fbcdn.net", post.icon
    assert_equal "2014-01-07 09:34:56 UTC", post.created_at.to_s
    assert_equal "2014-01-07 09:34:56 UTC", post.updated_at.to_s

    post_with_comments = adapter.posts.find { |post| post.id == "6798562721_10152175812797722" }

    comment = post_with_comments.comments.first

    assert_equal "10152175812797722_30527094", comment.id
    assert_match "In \"Confessions\" he didn't notice", comment.message
    assert_equal "1227159074", comment.author.id
    assert_equal "Greg Flint", comment.author.name
    assert_equal "2014-01-06 21:37:04 UTC", comment.created_at.to_s

    reply = comment.comments.first

    assert_equal "10152175812797722_30527131", reply.id
    assert_match "Thank you! Now it makes sense.", reply.message
    assert_equal "1632354093", reply.author.id
    assert_equal "John Vickers", reply.author.name
    assert_equal "2014-01-06 21:39:35 UTC", reply.created_at.to_s
  end

  test "should query messages" do
    page         = create :facebook_page, facebook_id: 93129637854
    access_token = create :facebook_access_token

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}/
    ).
    to_return(
      fixture "services/facebook/page.txt"
    )

    stub_request(
      :get, /graph.facebook.com\/#{page.facebook_id}\/conversations/
    ).
    to_return(
      fixture "services/facebook/page/conversations.txt"
    )

    adapter = Services::Facebook::Adapter.new page.facebook_id, access_token.token

    message = adapter.messages.first

    assert_equal "m_mid.1384444902346:5da3ba6be3efd78696", message.id
    assert_equal "NYOWMYGAWD", message.message
    assert_equal "2013-11-14 16:01:42 UTC", message.created_at.to_s
    assert_equal "Johannes Gorset", message.author.name
  end
end
