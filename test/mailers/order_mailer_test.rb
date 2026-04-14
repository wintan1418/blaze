require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "status_update" do
    mail = OrderMailer.status_update
    assert_equal "Status update", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
