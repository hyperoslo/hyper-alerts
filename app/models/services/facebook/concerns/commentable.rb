module Services::Facebook::Concerns::Commentable
  extend ActiveSupport::Concern

  included do
    embeds_many :comments, as: :commentable, order: :created_at.asc, class_name: "Services::Facebook::Comment" do

      # Comments by administrators of the Facebook page.
      def by_administrators
        where "author._id" => @base.page.facebook_id
      end

      # Comments by fans of the Facebook page.
      def by_fans
        where "author._id" => { "$ne" => @base.page.facebook_id }
      end

    end
  end
end
