require_relative "../lib/google_calendar_util"
require "test/unit"

class TestGoogleCalendarUtil < Test::Unit::TestCase

  def test_get_calendar_list
    cal_util = GoogleCalendarUtil.new(".google-api.yaml")
    cal_list = cal_util.get_calendar_list
  end

end

