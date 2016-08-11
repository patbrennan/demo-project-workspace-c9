# cms.rb - basic file-based content system.

require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "sinatra/content_for"
require "redcarpet"
require "yaml"
require "bcrypt"
# require "pry"

# The main benefit afforded by File.join is it will use the correct path
# separator based on the current operating system, which will be / on OS X
# and Linux and \ on Windows.

configure do
  enable :sessions
  set :session_secret, "secret_val"
  set :erb, :escape_html => true
end

helpers do
  # Convert markdown to html
  def render_markdown(file_text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(file_text)
  end
end

# Return correct test data path
def data_path
  ENV["RACK_ENV"] == "test" ? "tests/data" : "data"
end

# Test if new file submission has extension & isn't blank
def valid_file_name?(filename)
  return false if filename == ""
  !!filename.match(/(\.[a-z]{2,4}){1}/)
end

def user_signed_in?
  session.key?(:username)
end

# Redirect signed-out user for inappropriate actions
def require_sign_in
  unless user_signed_in?
    session[:message] = "You must be signed in to do that."
    redirect "/"
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

# Username / Password validation
def invalid_signup_credentials?(username, password)
  credentials = load_user_credentials
  requests_path = File.expand_path("../requests.yml", __FILE__)
  requests = YAML.load_file(requests_path)
  
  if credentials.key?(username) || requests.key?(username)
    :exists
  elsif password.size < 6
    :bad_password
  elsif username.size < 3
    :bad_username
  else
    false
  end
end

# Return reason sign-up data is invalid
def invalid_cred_reason(username, password)
  reason = invalid_signup_credentials?(username, password)
  
  case reason
  when :exists then "Username already exists."
  when :bad_username then "Username must be at least 3 characters long."
  when :bad_password then "Password must be at least 6 characters long."
  end
end

def submit_new_request(username, password)
  password = BCrypt::Password.create(password)

  File.open("requests.yml", "a+") do |file|
    file.write("\n#{username}: #{password}")
  end
end

before do
  session[:signed_in] ||= false
end

# Create a new file; must be located before "/" path or else might be interpreted
# as "/:filename"
get "/new" do
  require_sign_in
  erb :new
end

post "/create" do
  require_sign_in

  file_name = params[:filename].to_s.strip

  if valid_file_name?(file_name)
    File.write("#{data_path}/#{file_name}", "")

    session[:message] = "#{file_name} created."
    redirect "/"
  else
    session[:message] = "Invalid file name or format."
    status 422
    redirect "/new"
  end
end

get "/sign-up" do
  erb :sign_up
end

post "/sign-up" do
  username = params[:username]
  password = params[:password]

  if invalid_signup_credentials?(username, password)
    session[:message] = invalid_cred_reason(username, password)
    redirect "/sign-up"
  else
    submit_new_request(username, password)
    session[:message] = "Request submitted for admin approval."
    redirect "/"
  end
end

get "/" do
  @files = Dir.entries(data_path)
  @files.delete_if { |name| name == "." || name == ".." }
  erb :index
end

get "/sign-in" do
  erb :sign_in
end

post "/sign-in" do
  username = params[:username]
  pw_attempt = params[:password]

  if valid_login_credentials?(username, pw_attempt)
    session[:username] = username
    session[:signed_in] = true
    session[:message] = "Welcome!"
    redirect "/"
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
  redirect "/"
end

get "/:file_name" do
  @file_name = params[:file_name]

  if File.file?("#{data_path}/#{@file_name}")
    @content = File.read("#{data_path}/#{@file_name}")

    case File.extname(@file_name)
    when ".txt"
      headers["Content-Type"] = "text/plain"
      @content
    when ".md"
      erb render_markdown(@content)
    end
  else
    session[:message] = "#{@file_name} does not exist."
    redirect "/"
  end
end

# Render file edit page w/file content
get "/:file_name/edit" do
  require_sign_in

  @file_name = params[:file_name]

  unless File.file?("#{data_path}/#{@file_name}")
    session[:message] = "#{@file_name} does not exist."
    redirect "/"
  else
    @content = File.read("#{data_path}/#{@file_name}")
    erb :edit
  end
end

# Update the contents of a file
post "/:file_name/edit" do
  require_sign_in

  @file_name = params[:file_name]
  new_content = params[:new_content]

  File.open("#{data_path}/#{@file_name}", "w+") do |file|
    file.write(new_content)
  end

  session[:message] = "#{@file_name} updated."
  redirect "/"
end

# Delete one file
post "/:file_name/delete" do
  require_sign_in

  file = params[:file_name]

  File.delete("#{data_path}/#{file}")

  session[:message] = "#{file} deleted."
  redirect "/"
end
