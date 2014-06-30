require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  test "should sign" do
    invitation = create :invitation, key: "foobar"

    assert_equal "3415979b85796c6c39d4174a759ed9ba", invitation.sign
  end
end
