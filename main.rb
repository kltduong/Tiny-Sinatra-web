require 'sinatra/base'
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'
require './sinatra/auth'
require 'v8'
require 'coffee-script'

class Website < Sinatra::Base
  register Sinatra::Auth
  register Sinatra::Flash

  configure do
    enable :sessions
    set :username, 'kltduong'
    set :password, 'sinatra'
  end

  configure :development do
    set :email_address => 'smtp.gmail.com',
        :email_user_name => 'vtnusertest',
        :email_password => 'Ph@ntuluan',
        :email_domain => 'localhost.localdomain'
  end

#  configure :development do
#    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
#  end

#  configure :production do
#    DataMapper.setup(:default, ENV['DATABASE_URL'])
#  end

  before do
    set_title
  end

  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current?(path='/')
    (request.path == path || request.path == path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "About Vietnamese songs"
  end

  def send_message
    Pony.mail({
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'kltduong@gmail.com',
      :subject => params[:name] + " has contact you.",
      :body => params[:message],
      :via => :smtp,
      :via_options => {
        :address                => 'smtp.gmail.com',
        :port                   => '587',
        :enable_starttls_auto   => true,
        :user_name              => 'vtnusertest',
        :password               => 'Ph@ntuluan',
        :authentication         => :plain,
        :domain                 => 'localhost.localdomain'
      }
    })
  end

  get ('/styles.css') {scss :styles}
  get('/javascripts/application.js') {coffee :application}

  get '/' do
    slim :home
  end

  get '/about' do
    @title = "All About This Website"
    slim :about
  end

  get '/contact' do
    slim :contact#, :layout => :special
  end

  post '/contact' do
    send_message
    flash[:notice] = "Thank you for your message. You will be in touch soon."
    redirect to('/')
  end

  get '/instance' do
    @name = "DAZ"
    slim :show
  end

  get '/set/:name' do
    session[:name] = params[:name]
  end

  get '/get/hello' do
    "Hello #{session[:name]}"
  end

  get '/login' do
    slim :login
  end

  post '/login' do
    if params[:username] == settings.username && params[:password] == settings.password
      session[:admin] = true
      redirect to('/songs')
    else
      slim :login
    end
  end

  get '/logout' do
    session.clear
    redirect to('/login')
  end

  not_found do
    slim :not_found
  end
end

#@@show
#h1 Hello!
#== @name
