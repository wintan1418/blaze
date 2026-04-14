require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "home page loads and shows the hero headline" do
    visit root_path
    # Hero headline comes from SiteSetting.current — just confirm the page
    # rendered without errors. The exact headline text is customizable.
    assert_selector "h1"
  end
end
