# Customize Devise to redirect to the front page upon failing to authenticate
# the user.
class CustomDeviseFailureApp < Devise::FailureApp
  def redirect_url
    root_path
  end
end
