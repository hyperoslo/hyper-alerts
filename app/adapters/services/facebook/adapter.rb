class Services::Facebook::Adapter
  # Posts have a type, which is identified by an integer.
  POST_TYPE_GROUP_CREATED   = 11
  POST_TYPE_EVENT_CREATED   = 12
  POST_TYPE_STATUS_UPDATE   = 46
  POST_TYPE_POST_ON_WALL    = 56
  POST_TYPE_NOTE_CREATED    = 66
  POST_TYPE_LINK_POSTEd     = 80
  POST_TYPE_VIDEO_POSTED    = 128
  POST_TYPE_PHOTOS_POSTED   = 247
  POST_TYPE_APP_STORY       = 237
  POST_TYPE_APP_STORY_2     = 272 # Facebook has two enumerations for "app stories" for some reason
  POST_TYPE_COMMENT_CREATED = 257
  POST_TYPE_CHECKIN         = 285
  POST_TYPE_POST_IN_GROUP   = 308

  # Initialize the adapter.
  #
  # id           - A string describing a Facebook ID.
  # access_token - A string describing a Facebook access token.
  def initialize id, access_token
    @id           = id
    @access_token = access_token

    query
  end

  # Query Facebook's API.
  def query
    proxy_exceptions do
      # We need to query the page to determine whether it is accessible to the given access token,
      # as it will return a somewhat unambigious response ("false"), as opposed to that of its feed
      # (an empty array, which could just as easily mean that the page simply doesn't have any posts).
      @page = FbGraph::Page.fetch @id, access_token: @access_token, fields: "name,likes"
    end
  end

  # Query the page's name.
  def name
    @page.name
  end

  # Query the page's likes.
  def likes
    @page.like_count
  end

  # Query the page's photos.
  #
  # limit - An integer describing how many images to load.
  #
  # Returns an Array of Services::Facebook::Photo instances.
  def photos limit = 50
    query = {
      photos:   "SELECT object_id, caption, src_big, owner, link, caption, created FROM photo WHERE owner = #{@id} ORDER BY created DESC LIMIT #{limit}",
      comments: "SELECT id, fromid, time, text, object_id, parent_id FROM comment WHERE object_id IN(SELECT object_id FROM #photos) ORDER BY time DESC LIMIT 10",
      users:    "SELECT uid, name FROM user WHERE uid IN(SELECT owner FROM #photos) OR uid IN(SELECT fromid FROM #comments)",
      pages:    "SELECT page_id, name FROM page WHERE page_id IN(SELECT owner FROM #photos) OR page_id IN(SELECT fromid FROM #comments)"
    }

    proxy_exceptions do
      query = FbGraph::Query.new(query).fetch(access_token: @access_token)

      query[:photos].map do |photo_data|
        Services::Facebook::Photo.new do |photo|
          photo.id         = photo_data[:object_id]
          photo.link       = photo_data[:link]
          photo.source     = photo_data[:src_big]
          photo.caption    = photo_data[:caption]
          photo.created_at = Time.at photo_data[:created]

          ## The author of a video can be either a User or a Page.
          user_or_page_data = query[:users].find { |user_data| user_data[:uid] == photo_data[:owner] } ||
                              query[:pages].find { |page_data| page_data[:page_id] == photo_data[:owner] }

          # There may occasionally be no data for the author of a comment, despite the 'fromid' of the comment being
          # set to a valid Facebook ID. There's no documentation as to the circumstances under which this occurs, but it
          # is generally assumed that it is because the user that queries it doesn't have access to view it (for example,
          # the user could fall outside of geographical limitations set by the page that authored the comment).
          if user_or_page_data
            photo.author = new_user user_or_page_data
          end

          ## To find the post a comment belongs to, we must compare its 'object_id' attribute and to part of the post's id.
          comments_data = query[:comments].select { |comment_data| comment_data[:object_id] == photo_data[:object_id] }

          photo.comments = new_comments comments_data, users: query[:users], pages: query[:pages]
        end
      end
    end
  end

  # Query the page's videos.
  #
  # limit - An integer describing how many videosto load.
  #
  # Returns an Array of Services::Facebook::Video instances.
  def videos limit = 50
    query = {                                                                                                                                                                                                         
      videos:   "SELECT vid, title, thumbnail_link, src_hq, owner, created_time, updated_time FROM video WHERE owner = #{@id} ORDER BY created_time DESC LIMIT #{limit}",
      comments: "SELECT id, fromid, time, text, object_id, parent_id FROM comment WHERE object_id IN(SELECT vid FROM #videos) ORDER BY time DESC LIMIT 10",
      users:    "SELECT uid, name FROM user WHERE uid IN(SELECT owner FROM #videos) OR uid IN(SELECT fromid FROM #comments)",
      pages:    "SELECT page_id, name FROM page WHERE page_id IN(SELECT owner FROM #videos) OR page_id IN(SELECT fromid FROM #comments)"
    }

    proxy_exceptions do
      query = FbGraph::Query.new(query).fetch(access_token: @access_token)

      query[:videos].map do |video_data|
        Services::Facebook::Video.new do |video|
          video.id         = video_data[:vid]
          video.name       = video_data[:title]
          video.picture    = video_data[:thumbnail_link]
          video.source     = video_data[:src_hq]
          video.created_at = Time.at video_data[:created_time]
          video.updated_at = Time.at video_data[:updated_time]

          # The author of a video can be either a User or a Page.
          user_or_page_data = query[:users].find { |user_data| user_data[:uid] == video_data[:owner] } ||
                              query[:pages].find { |page_data| page_data[:page_id] == video_data[:owner] }

          # There may occasionally be no data for the author of a comment, despite the 'fromid' of the comment being
          # set to a valid Facebook ID. There's no documentation as to the circumstances under which this occurs, but it
          # is generally assumed that it is because the user that queries it doesn't have access to view it (for example,
          # the user could fall outside of geographical limitations set by the page that authored the comment).
          if user_or_page_data
            video.author = new_user user_or_page_data
          end

          # To find the post a comment belongs to, we must compare its 'object_id' attribute and to part of the post's id.
          comments_data = query[:comments].select { |comment_data| comment_data[:object_id] == video_data[:vid] }

          video.comments = new_comments comments_data, users: query[:users], pages: query[:pages]
        end
      end
    end
  end

  # Query the page's feed.
  #
  # limit - An integer describing how many posts to load.
  #
  # Returns an Array of Services::Facebook::Post instances.
  def posts limit = 50
    query = {
      posts:    "SELECT post_id, actor_id, message, description, attachment.name, attachment.href, attachment.caption, attachment.description, type,
                 attachment.icon, attachment.media, created_time, updated_time FROM stream WHERE source_id = #{@id} ORDER BY created_time DESC LIMIT #{limit}",
      comments: "SELECT id, fromid, time, text, object_id, parent_id FROM comment WHERE post_id IN(SELECT post_id FROM #posts) ORDER BY time DESC LIMIT 10",
      users:    "SELECT uid, name FROM user WHERE uid IN(SELECT actor_id FROM #posts) OR uid IN(SELECT fromid FROM #comments)",
      pages:    "SELECT page_id, name FROM page WHERE page_id IN(SELECT actor_id FROM #posts) OR page_id IN(SELECT fromid FROM #comments)"
    }

    proxy_exceptions do
      query = FbGraph::Query.new(query).fetch(access_token: @access_token)

      # Ignore posts that are created automatically following a video or photo, as we already alert about it anyway.
      query[:posts].delete_if do |post|
        post[:type].in? [POST_TYPE_VIDEO_POSTED, POST_TYPE_PHOTOS_POSTED]
      end

      query[:posts].map do |post_data|
        Services::Facebook::Post.new do |post|
          post.id          = post_data[:post_id]
          post.message     = post_data[:message]

          if post_attachment_data = post_data[:attachment]
            post.name        = post_attachment_data[:name]
            post.caption     = post_attachment_data[:caption]
            post.description = post_attachment_data[:description]
            post.icon        = post_attachment_data[:icon]

            if post_attachment_data[:media] && post_attachment_data[:media].any?
              post.picture = post_attachment_data[:media][0][:src]
            end
          end

          post.created_at  = Time.at post_data[:created_time]
          post.updated_at  = Time.at post_data[:updated_time]

          # The author of a post can be either a User or a Page.
          user_or_page_data = query[:users].find { |user_data| user_data[:uid] == post_data[:actor_id] } ||
                              query[:pages].find { |page_data| page_data[:page_id] == post_data[:actor_id] }

          # There may occasionally be no data for the author of a comment, despite the 'fromid' of the comment being
          # set to a valid Facebook ID. There's no documentation as to the circumstances under which this occurs, but it
          # is generally assumed that it is because the user that queries it doesn't have access to view it (for example,
          # the user could fall outside of geographical limitations set by the page that authored the comment).
          if user_or_page_data
            post.author = new_user user_or_page_data
          end

          # To find the post a comment belongs to, we must compare its 'object_id' attribute and to part of the post's id.
          comments_data = query[:comments].select { |comment_data| comment_data[:object_id] == post_data[:post_id].split("_").last }

          post.comments = new_comments comments_data, users: query[:users], pages: query[:pages]
        end
      end.compact
    end
  end

  # Query the page's messages.
  #
  # Returns an Array of Services::Facebook::Message instances.
  def messages
    proxy_exceptions do
      @page.conversations.map do |conversation|
        conversation.messages.map do |data|
          Services::Facebook::Message.new do |message|
            message.id         = data.identifier
            message.message    = data.message
            message.created_at = data.created_time
            message.author     = Services::Facebook::User.new do |user|
              user.id   = data.from.identifier
              user.name = data.from.name
            end
          end
        end
      end.flatten
    end
  end

  private

  def proxy_exceptions
    yield
  rescue FbGraph::InvalidToken => error
    raise Services::Facebook::AccessToken::Invalid, error
  rescue FbGraph::NotFound => error
    raise Services::Facebook::Page::Disappeared, error
  # Invalid requests are typically the result of access restrictions imposed on the given resource. For example,
  # Facebook will respond with "unsupported get request" (which in turn raises a FbGraph::InvalidResponse) upon
  # trying to access a Facebook page that is only available to people in Norway with an access token that belongs
  # to a user in Sweden.
  rescue FbGraph::InvalidRequest => error
    raise Services::Facebook::Page::Inaccessible, error
  end

  # Initialize comments from Facebook data.
  #
  # comments_data - An Array of Hashes describing comments with keys 'id', 'fromid', 'time', 'text', 'object_id' and 'parent_id'.
  # context       - A Hash describing context:
  #                 :users_data - An Array of Hashes describing users with keys according to the argument of Adapter#user.
  #                 :pages_data - An Array of Hashes describing users with keys according to the argument of Adapter#user.
  #
  # Returns an Array of Services::Facebook::Comment instances.
  def new_comments comments_data, context
    top_level_comments = comments_data.select { |comment_data| comment_data[:parent_id] == "0" }
    comment_replies    = comments_data.reject { |comment_data| comment_data[:parent_id] == "0" }

    top_level_comments.map do |comment_data|
      comment = new_comment comment_data, context

      comment_reply_datas_to_this_comment = comment_replies.select { |comment_reply_data| comment_reply_data[:parent_id] == comment_data[:id] }

      comment.comments = comment_reply_datas_to_this_comment.map do |comment_reply_data|
        new_comment comment_reply_data, context
      end

      comment
    end
  end

  # Initialize a comment from Facebook data.
  #
  # comment_data - An Hash describing comments with keys 'id', 'fromid', 'time', 'text', 'object_id' and 'parent_id'.
  # context      - A Hash describing context:
  #                :users_data - An Array of Hashes describing users with keys according to the argument of Adapter#user.
  #                :pages_data - An Array of Hashes describing users with keys according to the argument of Adapter#user.
  #
  # Returns a Services::Facebook::Comment instance.
  def new_comment comment_data, context
    users_data = context[:users]
    pages_data = context[:pages]

    Services::Facebook::Comment.new do |comment|
      comment.id         = comment_data[:id]
      comment.message    = comment_data[:text]
      comment.created_at = Time.at comment_data[:time]

      # The author of a comment can be either a User or a Page.
      user_or_page_data = users_data.find { |user_data| user_data[:uid] == comment_data[:fromid] } ||
                          pages_data.find { |page_data| page_data[:page_id] == comment_data[:fromid] }

      # There may occasionally be no data for the author of a comment, despite the 'fromid' of the comment being
      # set to a valid Facebook ID. There's no documentation as to the circumstances under which this occurs, but it
      # is generally assumed that it is because the user that queries it doesn't have access to view it (for example,
      # the user could fall outside of geographical limitations set by the page that authored the comment).
      if user_or_page_data
        comment.author = new_user user_or_page_data
      end
    end
  end

  # Initialize a new user from Facebook data.
  #
  # user_or_page_data - A Hash with keys 'uid' or 'page_id' and 'name'.
  #
  # Returns a Services::Facebook::User instance.
  def new_user user_or_page_data
    Services::Facebook::User.new do |user|
      # Facebook casts some IDs as strings and others as integers, but in the interest of being consistent and
      # future-proof we'll cast them all to strings.
      user.id   = (user_or_page_data[:uid] || user_or_page_data[:page_id]).to_s
      user.name = user_or_page_data[:name]
    end
  end
end
