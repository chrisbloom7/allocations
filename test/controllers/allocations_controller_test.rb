require "test_helper"

class AllocationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should show allocation" do
    post allocation_url, params: {
      allocation_amount: 100,
      investor_amounts: [
        { name: "Investor A", requested_amount: 150, average_amount: 100 },
        { name: "Investor B", requested_amount: 50, average_amount: 25 }
      ]
    }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 100, json_response["allocation_amount"]
    assert_equal 100, json_response["allocated"]
    assert_equal 0, json_response["remaining"]
    assert_equal "fully_funded", json_response["funding_status"]
  end
end
