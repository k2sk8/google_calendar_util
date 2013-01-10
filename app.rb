# coding: utf-8
# vim:set ts=2 expandtab shiftwidth=2:
require "rubygems"
#require "bundler/setup"
require "google/api_client"
require "yaml"
require "time"
require "date"
require "optparse"

cal_num = 0
opt = OptionParser.new
opt.banner = "Usage: #{$0} [-c num] [month] [year]"
opt.on('-c num','choose calendar number'){|v| cal_num = v.to_i - 1}
begin
  opt.parse!(ARGV)
rescue OptionParser::ParseError => err
  puts opt.help
  exit 1
end

#引数の処理
month,year = ARGV 

month = month.to_i
year = year.to_i
month = Time.now.month if month == 0 
year = Time.now.year if year == 0

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

# カレンダーのイベントを格納する
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
if cal_num < 0 then
  entries.each_with_index do |cal, index|
    #p cal
    puts (index + 1).to_s + ". " + cal.summary + "\n"
  end

  # ユーザーにカレンダーの番号を選択させる
  print "please input number you want to get events \n> "
  cal_num = gets.strip.to_i - 1
end
exit if cal_num < 0 || cal_num > entries.size - 1
#p cal_num

# ユーザーにカレンダーのイベントを取得する期間を指定させる
#print "what year? \n> "
#year = gets.strip.to_i
#print "what month? (1-12) \n> "
#month = gets.strip.to_i

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


def event_start_datetime(event)
  if event.start.date
    Time.parse(event.start.date)
  else
    event.start.dateTime
  end
end
def event_start_date(event)
  if event.start.date
    event.start.date
  else
    event.start.dateTime.strftime("%Y-%m-%d")
  end
end

def event_start_time(event)
  if event.start.date
    nil
  else
    event.start.dateTime.strftime("%H:%M")
  end
end

def event_end_date(event)
  if event.end.date
    event.end.date
  else
    event.end.dateTime.strftime("%Y-%m-%d")
  end
end

def event_end_time(event)
  if event.end.date
    nil
  else
    event.end.dateTime.strftime("%H:%M")
  end
end

# イベント一覧をCSVに書き出す
require "csv"

recurrings = []
event_hash = {}

events.each do |event|
  unless event.recurrence.empty? then
    recurrings.push(event)
    next
  end
  t = event_start_datetime(event)
  event_hash[t] = [event_start_date(event), event_start_time(event), event_end_date(event), event_end_time(event), event.summary]
end

time_min = Time.utc(year, month, 1, 0)
time_max = Time.utc(year, month, 31, 0)
recurrings.each do |event|
#	p event.id
#	p event.recurrence
  params = {"calendarId" => entries[cal_num].id,
    "eventId" => event.id
  }
  result = client.execute(:api_method => service.events.instances,
                          :parameters => params)
  events = result.data.items
  events.each do |event|
    t = event.start.dateTime
    next if (t.to_i < time_min.to_i || t.to_i > time_max.to_i)
#	  print t
#	  print event.summary + "\n"
    event_hash[t] = [event_start_date(event), event_start_time(event), event_end_date(event), event_end_time(event), event.summary]
  end
end

#CSV.open($stdout, "wb:Shift_JIS:UTF-8") do |csv|
CSV do |csv|
  event_hash.sort.each do |t,e|
   # puts e.join(',')
   # csv << [event_start_date, event_start_time, event_end_date, event_end_time, event.summary]
    csv << e
  end
end
