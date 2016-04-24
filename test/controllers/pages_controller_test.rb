require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get leaderlookup" do
    get :leaderlookup
    assert_response :success
  end

  test "should get teammanagement" do
    get :teammanagement
    assert_response :success
  end

  test "should get teamtotals" do
    get :teamtotals
    assert_response :success
  end

end
