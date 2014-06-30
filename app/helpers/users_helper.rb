module UsersHelper
  def facebook_permissions
    current_user.graph.permissions
  end
end
