ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "fileutils"

require "minitest/reporters"
Minitest::Reporters.use!

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Note that within test/cms_test.rb we are able to access the data_path method
  # defined in cms.rb because it is defined in a global scope.
  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content="")
    File.open("#{data_path}/#{name}", "w") do |file|
      file.write(content)
    end
  end

  def log_in(user, password)
    post "/sign-in", username: user, password: password
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    { "rack.session" => { username: "admin" } }
  end

  def assert_signed_out_message
    assert_equal "You must be signed in to do that.", session[:message]
  end

  def test_index
    log_in("admin", "admin123")

    create_document "about.txt"
    create_document "changes.txt"

    get last_response["Location"]

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    files = ["about.txt", "changes.txt"]
    files.each { |file| assert_includes last_response.body, file }
  end

  def test_file_display
    create_document "history.txt", "This is some text."

    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    file = File.read("#{data_path}/history.txt")
    assert last_response.body.include? file
  end

  def test_nonexisting_file
    get "/asddafoiw09.ext"
    assert_equal 302, last_response.status
    assert_equal "asddafoiw09.ext does not exist.", session[:message]
  end

  def test_md_render_html
    create_document "things.md", "# A Mark-Down file..."

    get "/things.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>A Mark-Down file...</h1>"
  end

  def test_edit_page
    create_document "things.md"

    get "/things.md/edit", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_edit_page_signed_out
    create_document "things.md"

    get "/things.md/edit"

    assert_equal 302, last_response.status
    assert_signed_out_message
  end

  def test_edit_file
    post "/changes.txt/edit", {new_content: "new content"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "changes.txt updated.", session[:message]
    
    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_edit_file_signed_out
    post "/changes.txt/edit", new_content: "new content"
    assert_equal 302, last_response.status
    assert_signed_out_message
  end

  def test_view_add_new
    get "/new", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Add a New Document:"
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_view_add_new_signed_out
    get "/new"
    assert_equal 302, last_response.status
    assert_signed_out_message
  end

  def test_add_new_file
    post "/create", {filename: "new_doc.txt"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "new_doc.txt created.", session[:message]

    get "/"
    assert_includes last_response.body, "new_doc.txt"
  end

  def test_create_new_document_without_filename
    post "/create", {filename: ""}, admin_session
    assert_equal 302, last_response.status
    assert_equal "Invalid file name or format.", session[:message]
  end

  def test_create_new_document_invalid_extension
    post "/create", {filename: "something"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "Invalid file name or format.", session[:message]
  end

  def test_delete_one_file
    create_document("delete_me.txt", "This is some dummy content")

    post "/delete_me.txt/delete", {}, admin_session
    assert_equal 302, last_response.status
    assert_equal "delete_me.txt deleted.", session[:message]

    get "/"
    refute_includes last_response.body, "<li>delete_me.txt"
  end

  def test_delete_one_file_signed_out
    create_document("delete_me.txt", "This is some dummy content")

    post "/delete_me.txt/delete"
    assert_equal 302, last_response.status
    
  end

  def test_not_logged_in
    get "/"
    assert_includes last_response.body, "You must sign in"
  end

  def test_signin_form
    get "/sign-in"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username:"
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_signin
    log_in("admin", "admin123")
    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]
    assert_includes last_response.body, "Logged in as admin"
  end

  def test_signin_with_bad_credentials
    log_in("guest", "wrong-password")
    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials"
  end

  def test_signout
    log_in("admin", "admin123")
    assert_equal "Welcome!", session[:message]
    get last_response["Location"]

    post "/sign-out"
    get last_response["Location"]

    assert_equal nil, session[:username]
    assert_includes last_response.body, "You have been signed out"
    assert_includes last_response.body, "Sign In"
  end
end
