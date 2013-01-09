# coding: utf-8
require "rubygems"
require "bundler/setup"
require "google/api_client"
require "yaml"
require "time"

# authorization
oauth_yaml = YAML.load_file('.google-api.yaml')
client = Google::APIClient.new
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

# client.authorization.expired? が常にfalseを返すので意味ない？
#if client.authorization.refresh_token && client.authorization.expired?
#  client.authorization.fetch_access_token!
#end

service = client.discovered_api('calendar', 'v3')
#p service

page_token = nil
result = client.execute(:api_method => service.calendar_list.list)
#p result.data

i = 0
if result.data["error"]
  if i == 3
    puts "error with #{result.data["error"]["errors"][0]["message"]}"
    exit
  end
  if client.authorization.refresh_token
    client.authorization.fetch_access_token!
  else
    puts "Get refresh token!"
    exit
  end
  result = client.execute(:api_method => service.calendar_list.list)
  i += 1
end

entries = []
while true
  result.data.items.each do |item|
    entries << item
  end
  if !(page_token = result.data.next_page_token)
    break
  end
  result = client.execute(:api_method => service.calendar_list.list,
                          :parameters => {'pageToken' => page_token})
end

# カレンダー一覧の出力
entries.each_with_index do |cal, index|
  #p cal
  puts (index + 1).to_s + ". " + cal.summary + "\n"
end

# ユーザーにカレンダーの番号を選択させる
print "please input number you want to get events \n> "
cal_num = gets.strip.to_i - 1
exit if cal_num < 0 || cal_num > entries.size - 1
#p cal_num

# ユーザーにカレンダーのイベントを取得する期間を指定させる
print "what year? \n> "
year = gets.strip.to_i
print "what month? (1-12) \n> "
month = gets.strip.to_i

# time_minとtime_maxはUTCで指定する(+9しない)
time_min = Time.utc(year, month, 1, 0).iso8601
time_max = Time.utc(year, month, 31, 0).iso8601
#exit

# 特定のカレンダーのイベントを取得する
params = {"calendarId" => entries[cal_num].id,
          "timeMax" => time_max,
          "timeMin" => time_min}
page_token = nil
result = client.execute(:api_method => service.events.list,
                        :parameters => params)

i = 0
if result.data["error"]
  if i == 3
    puts "error with #{result.data["error"]["errors"][0]["message"]}"
    exit
  end
  if client.authorization.refresh_token
    client.authorization.fetch_access_token!
  else
    puts "Get refresh token!"
    exit
  end
  result = client.execute(:api_method => service.events.list,
                          :parameters => params)
  i += 1
end

# カレンダーのイベントを格納する
events = []
while true
  result.data.items.each do |item|
    events << item
  end
  if !(page_token = result.data.next_page_token)
    break
  end
  params["pageToken"] = page_token
  result = client.execute(:api_method => service.events.list,
                          :parameters => params)
end


def event_start_date(event)
  if event.start.date
    event.start.date
  else
    event.start.dateTime.to_s.match(/^([\d]{4}-[\d]{2}-[\d]{2})\s([\d]{2}:[\d]{2})/)
    $1
  end
end

def event_start_time(event)
  if event.start.date
    nil
  else
    event.start.dateTime.to_s.match(/^([\d]{4}-[\d]{2}-[\d]{2})\s([\d]{2}:[\d]{2})/)
    $2
  end
end

# イベント一覧をCSVに書き出す
require "csv"

month = sprintf("%02d", month)
output_file = "data/event_#{year}#{month}.csv"
CSV.open(output_file, "wb:Shift_JIS:UTF-8") do |csv|
  events.each do |event|
    #if event.start.date
      #event_start_time = nil
    #else
      #event.start.dateTime.to_s.match(/^([\d]{4}-[\d]{2}-[\d]{2})\s([\d]{2}:[\d]{2})/)
      #event_start_time = $2
    #end

    if event.end.date
      event_end_date = event.end.date
      event_end_time = nil
    else
      event.end.dateTime.to_s.match(/^([\d]{4}-[\d]{2}-[\d]{2})\s([\d]{2}:[\d]{2})/)
      event_end_date = $1
      event_end_time = $2
    end
    csv << [event_start_date(event), event_start_time(event), event_end_date, event_end_time, event.summary]
  end
end

