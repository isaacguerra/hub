require "test_helper"

class Api::Chatbot::EventosControllerTest < ActionDispatch::IntegrationTest
  test "should list active events" do
    get api_chatbot_eventos_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response["eventos"]
    
    # Check if events are active (future date)
    first_event = json_response["eventos"].first
    assert Date.parse(first_event["data"]) >= Date.current
  end
end
