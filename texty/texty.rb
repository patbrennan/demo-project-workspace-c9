require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "rufus-scheduler"
require "yaml"
require "bcrypt"
require "twilio-ruby"
require "time"

def load_creds(key)
  creds = YAML.load_file("twilio_creds.yml")
  creds[key]
end

ENV["ACCOUNT_SID"] = load_creds("ACCOUNT_SID")
ENV["AUTH_TOKEN"] = load_creds("AUTH_TOKEN")

configure do
  enable :sessions
  set :session_secret, "MF*8^t%TY5KyW@fx"
  set :erb, :escape_html => true
end

helpers do
  def message_sent_history
    @account = Twilio::REST::Client.new ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"]
    @messages = @account.messages.list # delete @messages?
  end

  def can_reply?(from_number)
    from_number != "+17025087020"
  end

  def format_from(number)
    number.gsub(/\+/, "")
  end
  
  def format_sent(date)
    formatted = Time.parse(date)
    formatted = formatted.strftime("%B %d, %Y @ %H:%M UTC")
  end
end

def user_signed_in?
  session.key?(:username)
end

def require_sign_in
  unless user_signed_in?
    if session[:message]
      session[:message] = session[:message] + " You must sign in to continue."
    else
      session[:message] = " You must sign in to continue."
    end
    redirect "/sign-in"
  end
end

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../tests/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

def valid_login_credentials?(username, password)
  credentials = load_user_credentials
  
  if credentials.key?(username)
    bcrypt_pw = BCrypt::Password.new(credentials[username])
    bcrypt_pw == password
  else
    false
  end
end

def format_offset(offset)
  number = offset.scan(/[0-9]{1,2}/)[0]
  zeros = "0" if number.to_i < 10

  offset.chars.first + zeros + number + "00"
end

def format_date(time)
  month = time.month
  day = time.day
  year = time.year
  
  "#{year}/#{month}/#{day}"
end

def format_hours_minutes(time)
  hour = time.hour
  hour = "0" + hour.to_s if hour < 10

  minute = time.min
  minute = "0" + minutes.to_s if minute < 10

  "#{hour}:#{minute}"
end

# Format the time to be sent
def format_send_time(date, time, offset)
  "#{date} #{time}:00 #{offset}"
end

# Remove spaces, dashes, parens, etc
def format_number(raw_number)
  number = raw_number.gsub(/[^0-9]/, "")
  
  number.size <= 10 ? "+1#{number}" : "+#{number}"
end

# Simple validation if it is the correct length
def valid_phone_num?(number)
  number = number.gsub(/\+/, "")
  number.size == 11
end

# test that time is at least 15 seconds in the future.
def valid_time?(send_time, offset)
  offset = offset.insert(3, ":") # Convert to proper format for #localtime()

  now = (Time.now.localtime(offset) + 15).to_s
  send_time > now
end

def create_human_time(time)
  new_time = Time.parse(time)
  new_time.strftime("%B %d, %Y @ %I:%M %p")
end

def send_sms(recipient, message)
  client = Twilio::REST::Client.new(
    ENV["ACCOUNT_SID"],
    ENV["AUTH_TOKEN"]
  )
  
  client.messages.create(
    to: recipient,
    from: "+17025087020",
    body: message
  )
  # add sms to log w/status
end

def schedule_sms(recipient, message, time)
  scheduler = Rufus::Scheduler.new

  scheduler.at(time) do
    send_sms(recipient, message)
  end
end

before do
  session[:signed_in] ||= false
end

get "/" do
  redirect "/send-sms"
end

get "/send-sms" do
  require_sign_in
  erb :send
end

post "/send-sms" do
  recipient = format_number(params[:phone_number])
  @message = params[:body]
  offset = format_offset(params[:timezone])
  send_time = format_send_time(params[:date], params[:time], offset)
  
  if valid_phone_num?(recipient)
    if params[:send_now]
      send_sms(recipient, @message)
      session[:message] = "Message queued to: #{recipient}."
    elsif params[:schedule] && valid_time?(send_time, offset)
      schedule_sms(recipient, @message, send_time)
      time = create_human_time(send_time)
      session[:message] = "Message schedule for: #{time}."
    else
      session[:message] = "Please choose a time in the future, or click 'Send Now'"
    end
    redirect "/send-sms"
  else
    session[:message] = "Please choose a valid, 10-digit phone number."
    erb :send
  end
end

get "/receive-sms" do
  
end

post "/receive-sms" do
  content_type = "text/xml"
end

get "/sign-in" do
  erb :sign_in
end

post "/sign-in" do
  username = params[:username]
  password = params[:password]
  
  if valid_login_credentials?(username, password)
    session[:username] = username
    session[:signed_in] = true
    session[:message] = "Welcome!"
    redirect "/send-sms"
  else
    session[:message] = "Invalid Credentials"
    status 422
    erb :sign_in
  end
end

post "/sign-out" do
  session[:signed_in] = false
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/send-sms"
end

# For AJAX updating of history
get "/update-history" do
  erb :history
end
