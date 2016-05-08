require 'test_helper'

class AuditControllerTest < ActionController::TestCase
  test "should get audit" do
    get :audit
    assert_response :success
  end

end
