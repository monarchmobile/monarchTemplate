 
# 1. remove public/index.html & create file for private settings
run "rm public/index.html"
run "touch application.yml"
run "mv application.yml config/"
run "rm .gitignore"
run "touch .gitignore"
run "mkdir lib/validators"

if yes?("#{@app_name}_development already exists. \n
  Do you want to replace #{@app_name}_development?(y/n)")
  run "dropdb #{@app_name}_development"
  run "createdb -Ouser1 -Eutf8 #{@app_name}_development"
end
# gems
gem 'jquery-ui-rails', :group => :assets

gem 'rails', '3.2.8'
gem 'rake' , '>= 0.9.2'
gem 'jquery-rails'
gem 'client_side_validations'
gem 'best_in_place'
gem 'friendly_id'
  # To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'thin'
  #upload photos
gem "rmagick"
gem "carrierwave"

run 'bundle install'


gsub_file 'Gemfile', /#.*\n/, "\n"
gsub_file 'Gemfile', /\n^\s*\n/, "\n"
# remove commented lines and multiple blank lines from config/routes.rb
gsub_file 'config/routes.rb', /  #.*\n/, "\n"
gsub_file 'config/routes.rb', /\n^\s*\n/, "\n"

username = ask("Name the user that will own this database")
gsub_file 'config/database.yml', /^(  username: ).*$/, '\1%s' % username

###############################
## customiize application.rb ##
###############################

inject_into_file "config/application.rb",  
"
local_ENVs = File.expand_path('../application.yml', __FILE__)\n
if File.exists?(local_ENVs)
    config = YAML.load(File.read(local_ENVs))
    config.merge! config.fetch(Rails.env, {})
    config.each do |key, value|
      ENV[key] = value unless value.kind_of? Hash
    end
end\n
", :before => "module #{@app_name.camelize}"

inject_into_file "config/application.rb", 
  '    config.assets.initialize_on_precompile = false
  config.autoload_paths += Dir["#{config.root}/lib/**/"]
  config.action_mailer.default_url_options = { host: ENV["MAILER_HOST"] }', 
  :after => "config.assets.version = '1.0'\n"

###############################
## customiize development.rb ##
###############################

inject_into_file 'config/environments/development.rb',
'  config.action_mailer.perform_deliveries = true
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: ENV["GMAIL_USERNAME"],
    password: ENV["GMAIL_PASSWORD"]
  }', :after => "config.action_mailer.raise_delivery_errors = false\n"

###############################
## customiize production.rb ##
###############################

gsub_file 'config/environments/production.rb', /# config.action_mailer.raise_delivery_errors = false/ do
  <<-RUBY
config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: ENV["GMAIL_USERNAME"],
    password: ENV["GMAIL_PASSWORD"]
  }
  RUBY
 end

################################
## create application.yml ##
################################

username = ask("gmail username (example@gmail.com)")
password = ask("gmail password")
append_file "config/application.yml", 
"GMAIL_USERNAME: '#{username}'
GMAIL_PASSWORD: '#{password}'

development:
  MAILER_HOST: 'localhost:3000'

production:
  MAILER_HOST: 'HEROKU_APP.com'"

################
## .gitignore ##
################
  
run "cp ~/sites/startup_template/gitignore_file ~/sites/#{@app_name}/.gitignore"

#################################
## add secret_token to app.yml ##
#################################

# before adding project to the repo, we remove sensitive data. e.g. the secret token
gsub_file 'config/initializers/secret_token.rb', /secret_token *= *'.+'/, "secret_token = ENV['SECRET_TOKEN']"
# add secret token in ignored application.yml file.
secret_token = SecureRandom.hex(64)
append_to_file 'config/application.yml', "\n\nSECRET_TOKEN: '#{secret_token}'"

# create app_vars file for app
pathname = "~/sites/startup_template/app_vars/#{@app_name}_env_vars.rb"
if pathname
  run "rm #{pathname}"
end

run "touch #{pathname}"
append_to_file "#{pathname}",
"heroku config:add GMAIL_USERNAME=#{username} GMAIL_PASSWORD=#{password} SECRET_TOKEN=#{secret_token} MAILER_HOST=HEROKU_APP.com"

#####################################
## app/assets/application.js & css ##
#####################################

# assets/javascripts/application.js references
inject_into_file 'app/assets/javascripts/application.js', 
"//= require jquery.ui.datepicker
//= require rails.validations
//= require best_in_place
//= require best_in_place.purr\n",
:after => "//= require jquery_ujs\n"

# assets/javascripts/application.css references
inject_into_file 'app/assets/stylesheets/application.css', 
" *= require jquery.ui.datepicker\n",
:before => " *= require_self\n"

# prepare client_side_validations
generate "client_side_validations:install"
run "cp ~/sites/startup_template/config/initializers/client_side_validations.rb ~/sites/#{@app_name}/config/initializers/client_side_validations.rb"

# prepare Uploader
generate "uploader image"

#######################################
## User Model -- Dynamic Content ##
#######################################

if yes?("Should we set up the User model now?(y/n)")
  model = ask("Name of User Model")
  columns_to_add = ask("List all attributes (column_name:type). email, admin, password_digest, first_name, last_name already included ")
  base_columns = "email:string password_digest:string admin:boolean auth_token:string password_reset_token:string password_reset_sent_at:datetime first_name:string last_name:string"
  # 10. build first model KEEP
  generate(:scaffold, "#{model} #{base_columns} #{columns_to_add}")

  gsub_file "app/models/#{model}.rb", ", :password_digest", ""
  gsub_file "app/models/#{model}.rb", ", :auth_token", ""
  inject_into_file "app/models/#{model}.rb", 
  "  attr_accessible :password, :password_confirmation, :fullname\n
  has_secure_password
  validates_presence_of :password, :on => :create
  before_create { generate_token(:auth_token) }

  # pretty url
  extend FriendlyId
  friendly_id :last_name

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def fullname 
    [first_name, last_name].join(' ')
  end

  def fullname=(name)
  split = name.split(' ', 2)
  self.first_name = split[0]
  self.last_name = split[1]
  end\n",
  :before => "end"
  
  rake "db:migrate"

#######################################
## Create sessions_controller ##
#######################################

  generate "controller sessions new"
  gsub_file "config/routes.rb", 'get "sessions/new"', ""

 ## controllers/sessions_controller.rb
  run "cp ~/sites/startup_template/controllers/sessions_controller.rb ~/sites/#{@app_name}/app/controllers/sessions_controller.rb"

  gsub_file "app/controllers/sessions_controller.rb", "Model_Name", "#{model.capitalize}"
## views/sessions/new.html.erb
  run "cp ~/sites/startup_template/views/sessions/new.html.erb ~/sites/#{@app_name}/app/views/sessions/new.html.erb"

#######################################
## Create password_resets_controller ##
#######################################

  generate "controller password_resets new"
  gsub_file "config/routes.rb", 'get "password_resets/new"', ""

## controllers/password_resets_controller.rb
  run "cp ~/sites/startup_template/controllers/password_resets_controller.rb ~/sites/#{@app_name}/app/controllers/password_resets_controller.rb"

## views/password_resets/new.html.erb
  run "cp ~/sites/startup_template/views/password_resets/new.html.erb ~/sites/#{@app_name}/app/views/password_resets/new.html.erb"

## views/password_resets/edit.html.erb
  run "cp ~/sites/startup_template/views/password_resets/edit.html.erb ~/sites/#{@app_name}/app/views/password_resets/edit.html.erb"

#######################################
## Create User Mailer ##
#######################################

generate "mailer user_mailer password_reset"
## mailer/user_mailer.rb
  run "cp ~/sites/startup_template/mailers/user_mailer.rb ~/sites/#{@app_name}/app/mailers/user_mailer.rb"
## user_mailer/password_reset.text.erb
  run "cp ~/sites/startup_template/views/user_mailer/password_reset.text.erb ~/sites/#{@app_name}/app/views/user_mailer/password_reset.text.erb"

#######################################
## User files ##
#######################################

## views/password_resets/edit.html.erb
  run "mkdir app/views/shared"
  run "cp ~/sites/startup_template/views/shared/_errors.html.erb ~/sites/#{@app_name}/app/views/shared/_errors.html.erb"
  run "cp ~/sites/startup_template/views/shared/_authentication.html.erb ~/sites/#{@app_name}/app/views/shared/_authentication.html.erb"

  run "rm app/views/#{model}s/_form.html.erb"
  run "touch app/views/#{model}s/_form.html.erb"
  append_to_file "app/views/#{model}s/_form.html.erb",
  "<%= form_for @#{model.downcase}, validate: true do |f| %>
  <%= render 'shared/errors', object: @#{model.downcase} %>
  <%= render('shared/authentication', f: f) if @#{model.downcase}.new_record? %>
  <div class='actions'>
    <%= f.submit %>
  </div>
<% end %>"

##########################
## application_helper.rb##
##########################

  run "cp ~/sites/startup_template/helpers/application_helper.rb ~/sites/#{@app_name}/app/helpers/application_helper.rb"

########################################
## Config.routes.rb -- Dynamic content##
########################################

  inject_into_file "config/routes.rb", 
  "  resources :sessions
  resources :password_resets", 
  :after => "resources :#{model.downcase}s\n"

  inject_into_file "config/routes.rb", 
  "match 'signup', to: '#{model}s#new'
  match 'logout', to: 'sessions#destroy'
  match 'login', to: 'sessions#new'\n", 
  :before => "resources :#{model.downcase}s"

#################################################
## application_controller.rb -- Dynamic content##
#################################################

# create, customize and reference helpers/base_helper.rb
  inject_into_file "app/controllers/application_controller.rb", 
  "  helper :all
  private

  def current_user
    @current_user ||= #{model.capitalize}.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end
  helper_method :current_user\n",
  :after => "protect_from_forgery\n"

  #######################################
  ## assets/stylesheets/users.css.scss ##
  #######################################

  append_to_file "app/assets/stylesheets/#{model}s.css.scss",
  ".required_field{
  margin-left:5px;
  color:#FF9494;
  display:inline-block;
  }"

  if yes?("set up Admin now?")
    admin_first_name = ask("First Name?")
    admin_last_name = ask("Last Name?")
    admin_email = ask("email")
    admin_password = ask("password")
    
    puts
    say_status  "Database", "Seeding the database with data...", :yellow
    puts        '-'*80, ''; sleep 0.25

    append_to_file 'db/seeds.rb',
    "#{model.capitalize}.create(
      first_name: '#{admin_first_name}',
      last_name: '#{admin_last_name}',
      email: '#{admin_email}',
      password: '#{admin_password}',
      admin: true
      )"

    rake "db:seed"
  end
end

if yes?("Should we create the StaticPagesController now? (y/n)")
  controller_name = ask("name of controller? (ie. Static_pages) ")
  controller_methods = ask("include methods? (ie. home profile about; keep in desired header order)")
  generate :controller, controller_name, controller_methods

  methods = controller_methods.split(" ")
  methods.each do |m|
    inject_into_file "config/routes.rb", 
    "match '#{m}', to: '#{controller_name}##{m}'\n",
    :after => "#{@app_name.camelize}::Application.routes.draw do\n"
  end
    
    file_name = 'config/routes.rb'
  tmp = File.read(file_name)
  methods.each do |m|
    ret = tmp.gsub(/get "#{controller_name}\/#{m}"/, "")
    File.open(file_name, 'w') {|file| file.puts ret}
  end

  run "cp ~/sites/startup_template/views/shared/_header.html.erb ~/sites/#{@app_name}/app/views/shared/_header.html.erb"
  
  methods.reverse.each do |method| 
    if method == "profile"
      inject_into_file "app/views/shared/_header.html.erb",
          "<%= link_to content_tag(:li, '#{method.capitalize}'), user_path(current_user.last_name) %>\n",
          :after => '<ul class="middle nav_bar">'
        else 
          inject_into_file "app/views/shared/_header.html.erb",
          "<%= link_to content_tag(:li, '#{method.capitalize}'), #{method}_path %>\n",
          :after => '<ul class="middle nav_bar">'
        end
  end
  route "root to: '#{controller_name}##{methods[0]}'"
  inject_into_file "app/views/layouts/application.html.erb", "<%= render 'shared/header' %>",
    :after => "<body>"

  run "cp ~/sites/startup_template/assets/stylesheets/controller.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/#{controller_name.downcase}.css.scss"
  
end

# scaffolds.css.scss **********
run "cp ~/sites/startup_template/assets/stylesheets/scaffolds.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/scaffolds.css.scss"

git :init
git add: "." 
git commit: %Q{ -m 'Initial commit' }