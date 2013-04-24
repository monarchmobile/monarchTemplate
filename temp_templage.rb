# create files
run "rm public/index.html"
run "touch application.yml && mv application.yml config/"
run "rm .gitignore"
run "touch .gitignore"
run "mkdir lib/validators"
run "cp ~/sites/startup_template/gitignore_file ~/sites/#{@app_name}/.gitignore"

## works works & disabled ##
##############
## check DB ##
##############
	if yes?("#{@app_name}_development already exists. \n
	  Do you want to replace #{@app_name}_development?(y/n)")
	  run "dropdb #{@app_name}_development"
	  run "createdb -Ouser1 -Eutf8 #{@app_name}_development"
	end

## works & disabled ##
##################
## preload gems ##
##################
  gem 'devise'
	gem 'cancan'
	gem 'rake' , '>= 0.9.2'
	gem "jquery-ui-rails", :group => :assets
	gem 'jquery-rails'
	gem "thin"
	# gem 'rmagick', '2.13.2', :git=>'http://github.com/rmagick/rmagick.git'
	# gem "carrierwave"
	# gem "ckeditor"
	# gem "mini_magick"
	gem 'friendly_id'
	# gem 'fog'
	# gem 'client_side_validations'
	# gem 'best_in_place'

	# run "cp ~/sites/startup_template/app/Gemfile ~/sites/#{@app_name}/app/Gemfile "

	run 'bundle install'

## works ##
##################################################################
## getting rid of comments and spacing in gemfile and routes.rb ##
##################################################################

	gsub_file 'Gemfile', /#.*\n/, "\n"
	gsub_file 'Gemfile', /\n^\s*\n/, "\n"
	# remove commented lines and multiple blank lines from config/routes.rb
	gsub_file 'config/routes.rb', /  #.*\n/, "\n"
	gsub_file 'config/routes.rb', /\n^\s*\n/, "\n"

	gsub_file 'config/database.yml', /  #.*\n/, "\n"
	gsub_file 'config/database.yml', /\n^\s*\n/, "\n"

	username = ask("Name the user that will own this database")
	gsub_file 'config/database.yml', /^(  username: ).*$/, '\1%s' % username

## works ##
###############################
## customiize application.rb ##
###############################

inject_into_file 'config/application.rb', :before => "module #{@app_name.camelize}" do <<-'RUBY'
local_ENVs = File.expand_path('../application.yml', __FILE__)

if File.exists?(local_ENVs)
    config = YAML.load(File.read(local_ENVs))
    config.merge! config.fetch(Rails.env, {})
    config.each do |key, value|
      ENV[key] = value unless value.kind_of? Hash
    end
end
RUBY
end


inject_into_file 'config/application.rb', :after => "config.assets.version = '1.0'\n" do <<-'RUBY'
	config.assets.initialize_on_precompile = false
	config.action_mailer.default_url_options = { host: ENV['MAILER_HOST'] }
	config.serve_static_assets = true
	config.assets.precompile += ['static_pages.css']
	config.autoload_paths += %W(#{config.root}/app/models/ckeditor #{config.root}/lib)
RUBY
end

## works ##
###############################
## customiize development.rb ##
###############################

inject_into_file 'config/environments/development.rb', :after => "config.action_mailer.raise_delivery_errors = false\n" do <<-'RUBY'
	config.action_mailer.perform_deliveries = true
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
	}
RUBY
end

## works ##
###############################
## customiize production.rb ##
###############################

gsub_file 'config/environments/production.rb', /# config.action_mailer.raise_delivery_errors = false/ do <<-'RUBY'
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

## testing ##
###############################
## customiize routes.rb #######
###############################

inject_into_file 'config/routes.rb', :after => "#{@app_name.camelize}::Application.routes.draw do\n" do <<-'RUBY'
	# mount Ckeditor::Engine => '/ckeditor'
  resources :pages
  resources :products
  resources :contacts
  resources :links
  resources :supermodels

  resources :articles do
    resources :comments
  end

  

  match 'dashboard', :to => 'static_pages#dashboard'
  match 'article_index', :to => 'articles#article_index'
  # match "users/:id/update", to: "users#update"

  
  root :to => "pages#show", :id => 'home'
RUBY
end

## works ##
################################
## create application.yml ##
################################
puts say_status "","We are going to set up your hosting email through GMAIL.  This will be used for sending emails to all members"
username = ask("gmail username (example@gmail.com)")
password = ask("gmail password")
append_file "config/application.yml", 
"\n
GMAIL_USERNAME: '#{username}'
GMAIL_PASSWORD: '#{password}'

development:
  MAILER_HOST: 'localhost:3000'
  AWS_ACCESS_KEY_ID: ''
  AWS_SECRET_ACCESS_KEY: ''
  AWS_S3_BUCKET: '#{@app_name}_development'

staging:
  MAILER_HOST: 'quiet-thicket-3184.herokuapp.com'
  AWS_ACCESS_KEY_ID: ''
  AWS_SECRET_ACCESS_KEY: ''
  AWS_S3_BUCKET: '#{@app_name}_staging'

production:
  MAILER_HOST: 'HEROKU_APP.com'
  AWS_ACCESS_KEY_ID: ''
  AWS_SECRET_ACCESS_KEY: ''
  AWS_S3_BUCKET: '#{@app_name}_production'"


## works ##
#################################
## add secret_token to app.yml ##
#################################

# before adding project to the repo, we remove sensitive data. e.g. the secret token
gsub_file 'config/initializers/secret_token.rb', /secret_token *= *'.+'/, "secret_token = ENV['SECRET_TOKEN']"
# add secret token in ignored application.yml file.
secret_token = SecureRandom.hex(64)
append_to_file 'config/application.yml', "\n\nSECRET_TOKEN: '#{secret_token}'"

## testing ##
##################################
## create app_vars file for app ##
##################################

pathname = "~/sites/startup_template/app_vars/#{@app_name}_env_vars.rb"
if pathname
  run "rm #{pathname}"
end

run "touch #{pathname}"
append_to_file "#{pathname}",
"heroku config:add GMAIL_USERNAME=#{username} GMAIL_PASSWORD=#{password} SECRET_TOKEN=#{secret_token} MAILER_HOST=HEROKU_APP.com"

## works ##
###############################
## app/assets/application.js ##
###############################

inside('app/assets/javascripts') do
  run 'rm application.js'
  file 'application.js', <<-FILE
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
// 
//= require jquery
//= require jquery-ui
//= require rails.validations
//= require jquery_ujs

//= require_tree .

FILE
end

################################
## app/assets/application.css ##
################################
inside('app/assets/stylesheets') do
  run 'rm application.css'
  file 'application.css.scss', <<-FILE
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets/application, vendor/assets/stylesheets/application,
 * or vendor/assets/stylesheets/application of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require jquery.ui.datepicker
 *= require blog.css
 *= require scaffolds.css
 *= require comments.css
 
 */
FILE
end

#################
## generations ##
#################

##### client_side_validations #####
# generate "client_side_validations:install"
# run "cp ~/sites/startup_template/config/initializers/client_side_validations.rb ~/sites/#{@app_name}/config/initializers/client_side_validations.rb"

##### prepare Uploader #####
# generate "uploader image"

##### prepare Devise #####
generate "devise:install"
generate "devise user"
rake "db:migrate"
generate "devise:views"
generate "migration add_username_to_users username first_name last_name"


inject_into_file "config/routes.rb", :after => "devise_for :users" do <<-'RUBY'
, path_names: {sign_in: 'login', sign_out: 'logout'}
RUBY
end


####################################
## rails g models and controllers ##
####################################

################
## migrations ##
################

# db/migrate
run "cp ~/sites/startup_template/db/migrate/20130307183857_roles.rb ~/sites/#{@app_name}/db/migrate/20130307183857_roles.rb"
run "cp ~/sites/startup_template/db/migrate/20130307183748_user_roles.rb ~/sites/#{@app_name}/db/migrate/20130307183748_user_roles.rb"


# models
generate "model Page title:string slug:string content:text published:boolean index:integer"
generate "model Supermodel name:string visible:boolean"
generate ""

#controllers
generate "controller Pages"

#rake all migrations
rake "db:migrate"


################
## app/models ##
################

# ability.rb
run "touch app/models/ability.rb"
run "cp ~/sites/startup_template/app/models/ability.rb ~/sites/#{@app_name}/app/models/ability.rb"
# page.rb
run "cp ~/sites/startup_template/app/models/page.rb ~/sites/#{@app_name}/app/models/page.rb"
# role.rb
run "touch app/models/role.rb"
run "cp ~/sites/startup_template/app/models/role.rb ~/sites/#{@app_name}/app/models/role.rb"

# user.rb
inject_into_file "app/models/user.rb", :after => "attr_accessible :email, :password, :password_confirmation, :remember_me\n" do <<-'RUBY'
	attr_accessible :first_name, :last_name, :role, :username
	has_and_belongs_to_many :roles
  before_create :setup_role
  ## acts_as_orderer

  

  def role?(role)
   return !!self.roles.find_by_name(role.to_s)
  end

  def fullname
  	[first_name, last_name].join(" ")
  end

  def fullname=(name)
  	split = name.split(" ")
  	first_name = split[0]
  	last_name = split[1]
  end

  private
  def setup_role
  	guest = Role.find_by_name("Guest")

    if self.role_ids.empty?
      self.role_ids = [guest.id]
    end
  end
RUBY
end

############################
## app/assets/stylesheets ##
############################

run "touch app/assets/stylesheets/blog.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/blog.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/blog.css.scss"
run "touch app/assets/stylesheets/scaffolds.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/scaffolds.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/scaffolds.css.scss"
run "touch app/assets/stylesheets/static_pages.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/static_pages.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/static_pages.css.scss"


#####################
## app/controllers ##
#####################

# application_controller.rb
run "cp ~/sites/startup_template/app/controllers/application_controller.rb ~/sites/#{@app_name}/app/controllers/application_controller.rb"
# pages_controller.rb
run "cp ~/sites/startup_template/app/controllers/pages_controller.rb ~/sites/#{@app_name}/app/controllers/pages_controller.rb"
# static_pages_controller.rb
run "touch app/controllers/static_pages_controller.rb"
run "cp ~/sites/startup_template/app/controllers/static_pages_controller.rb ~/sites/#{@app_name}/app/controllers/static_pages_controller.rb"
# supermodels.rb
run "touch app/controllers/supermodels_controller.rb"
run "cp ~/sites/startup_template/app/controllers/supermodels_controller.rb ~/sites/#{@app_name}/app/controllers/supermodels_controller.rb"

#####################
## app/views ##
#####################

# layouts
run "cp ~/sites/startup_template/app/views/layouts/application.html.erb ~/sites/#{@app_name}/app/views/layouts/application.html.erb"
run "cp ~/sites/startup_template/app/views/layouts/dashboard.html.erb ~/sites/#{@app_name}/app/views/layouts/dashboard.html.erb"

# pages
run "mkdir app/views/pages"
run "cp ~/sites/startup_template/app/views/pages/_form.html.erb ~/sites/#{@app_name}/app/views/pages/_form.html.erb"
run "cp ~/sites/startup_template/app/views/pages/edit.html.erb ~/sites/#{@app_name}/app/views/pages/edit.html.erb"
run "cp ~/sites/startup_template/app/views/pages/index.html.erb ~/sites/#{@app_name}/app/views/pages/index.html.erb"
run "cp ~/sites/startup_template/app/views/pages/new.html.erb ~/sites/#{@app_name}/app/views/pages/new.html.erb"
run "cp ~/sites/startup_template/app/views/pages/show.html.erb ~/sites/#{@app_name}/app/views/pages/show.html.erb"

# shared
run "mkdir app/views/shared"
run "cp ~/sites/startup_template/app/views/shared/_authentication.html.erb ~/sites/#{@app_name}/app/views/shared/_authentication.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_errors.html.erb ~/sites/#{@app_name}/app/views/shared/_errors.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_header.html.erb ~/sites/#{@app_name}/app/views/shared/_header.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_footer.html.erb ~/sites/#{@app_name}/app/views/shared/_footer.html.erb"


#static_pages
run "mkdir app/views/static_pages"
run "cp ~/sites/startup_template/app/views/static_pages/dashboard.html.erb ~/sites/#{@app_name}/app/views/static_pages/dashboard.html.erb"

#supermodels
run "mkdir app/views/supermodels/"
run "cp ~/sites/startup_template/app/views/supermodels/_form.html.erb ~/sites/#{@app_name}/app/views/supermodels/_form.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/edit.html.erb ~/sites/#{@app_name}/app/views/supermodels/edit.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/index.html.erb ~/sites/#{@app_name}/app/views/supermodels/index.html.erb"

###############
## lib/tasks ##
###############
run "cp ~/sites/startup_template/lib/tasks/create_links.rake ~/sites/#{@app_name}/lib/tasks/create_links.rake"
run "cp ~/sites/startup_template/lib/tasks/create_monarchAdmins.rake ~/sites/#{@app_name}/lib/tasks/create_monarchAdmins.rake"
run "cp ~/sites/startup_template/lib/tasks/create_roles.rake ~/sites/#{@app_name}/lib/tasks/create_roles.rake"


###################
## assets/images ##
###################
run "cp ~/sites/startup_template/assets/images/sidebar.png ~/sites/#{@app_name}/assets/images/sidebar.png"


###############
## db/seeds.rb ##
###############
append_to_file "db/seeds.rb", '
	Page.create(title: "home", content: "this is your home pag")
	Page.create(title: "about", content: "this is your about pag")'

rake "db:seed"










