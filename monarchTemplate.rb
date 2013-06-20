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

	gem "thin"
	# gem 'rmagick', '2.13.2', :git=>'http://github.com/rmagick/rmagick.git'
	gem "carrierwave"
	gem 'friendly_id'
	# gem 'client_side_validations'
	gem 'best_in_place'
  gem "ckeditor"
  gem "mini_magick"
  gem 'fog'


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

	username = ask("Name the user that will own this database")
	gsub_file 'config/database.yml', /^(  username: ).*$/, '\1%s' % username

## works ##
###############################
## customiize application.rb ##
###############################

inject_into_file 'config/application.rb', :after => "require 'rails/all'\n" do <<-'RUBY'
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

  resources :roles
  resources :users do 
    collection { post :sort }
  end
  resources :profiles
  resources :links
  resources :partials

  match "announcement_partial", :to => "announcements#announcement_partial"
  match "blog_partial", :to => "blogs#blog_partial"
  match "event_partial", :to => "events#event_partial"

  # announcements
  match 'announcements/:id/hide', to: 'announcements#hide', as: 'hide_announcement'
  resources :announcements do
    collection { post :sort }
  end
  match "announcements/:id/announcement_status", to: "announcements#announcement_status", as: "announcement_status"
  match "announcements/:id/announcement_starts_at", to: "announcements#announcement_starts_at", as: "announcement_starts_at"
  match "announcements/:id/announcement_ends_at", to: "announcements#announcement_ends_at", as: "announcement_ends_at"
  
  # blogs
  resources :blogs do
    resources :comments
    collection { post :sort }
  end
  match 'blogs/:id/blog_status', to: 'blogs#blog_status', as: 'blog_status'
  match "blogs/:id/blog_starts_at", to: "blogs#blog_starts_at", as: "blog_starts_at"
  match "blogs/:id/blog_ends_at", to: "blogs#blog_ends_at", as: "blog_ends_at"
  
  # events
  resources :events do
    collection { post :sort }
  end
  match 'events/:id/event_status', to: 'events#event_status', as: 'event_status'
  match "events/:id/event_starts_at", to: "events#event_starts_at", as: "event_starts_at"
  match "events/:id/event_ends_at", to: "events#event_ends_at", as: "event_ends_at"

  # pages
  resources :pages do
    collection { post :sort }
  end
  match 'pages/:id/status', to: 'pages#status', as: 'status'

  # supermodels
  resources :supermodels do
    collection { post :sort }
  end
  match "supermodels/:id/model_status", :to => "supermodels#model_status", :as => "model_status"

  match 'dashboard', :to => 'static_pages#dashboard'
  
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
//= require ckeditor/init
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
 *= require announcements.css
 *= require blogs.css
 *= require events.css
 *= require scaffolds.css

 
 */
FILE
end

#################
## generations ##
#################

##### client_side_validations #####
# generate "client_side_validations:install"
# run "cp ~/sites/startup_template/config/initializers/client_side_validations.rb ~/sites/#{@app_name}/config/initializers/client_side_validations.rb"
generate "ckeditor:install --orm=active_record --backend=carrierwave"
run "cp ~/sites/startup_template/config/initializers/ckeditor.rb ~/sites/#{@app_name}/config/initializers/ckeditor.rb"


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
run "cp ~/sites/startup_template/db/migrate/20130414164545_create_announcements.rb ~/sites/#{@app_name}/db/migrate/20130414164545_create_announcements.rb"
run "cp ~/sites/startup_template/db/migrate/20130417121515_create_blogs.rb ~/sites/#{@app_name}/db/migrate/20130417121515_create_blogs.rb"
run "cp ~/sites/startup_template/db/migrate/20130417121616_create_comments.rb ~/sites/#{@app_name}/db/migrate/20130417121616_create_comments.rb"
run "cp ~/sites/startup_template/db/migrate/20130418072626_create_events.rb ~/sites/#{@app_name}/db/migrate/20130418072626_create_events.rb"
run "cp ~/sites/startup_template/db/migrate/20130414104545_create_links.rb ~/sites/#{@app_name}/db/migrate/20130414104545_create_links.rb"
run "cp ~/sites/startup_template/db/migrate/20130414105555_create_pages.rb ~/sites/#{@app_name}/db/migrate/20130414105555_create_pages.rb"
run "cp ~/sites/startup_template/db/migrate/20130414105252_create_page_links.rb ~/sites/#{@app_name}/db/migrate/20130414105252_create_page_links.rb"
run "cp ~/sites/startup_template/db/migrate/20130419075050_create_page_partials.rb ~/sites/#{@app_name}/db/migrate/20130419075050_create_page_partials.rb"
run "cp ~/sites/startup_template/db/migrate/20130419074646_create_partials.rb ~/sites/#{@app_name}/db/migrate/20130419074646_create_partials.rb"
run "cp ~/sites/startup_template/db/migrate/20130414102121_create_profiles.rb ~/sites/#{@app_name}/db/migrate/20130414102121_create_profiles.rb"
run "cp ~/sites/startup_template/db/migrate/20130307183857_create_roles.rb ~/sites/#{@app_name}/db/migrate/20130307183857_create_roles.rb"
run "cp ~/sites/startup_template/db/migrate/20130414150909_create_statuses.rb ~/sites/#{@app_name}/db/migrate/20130414150909_create_statuses.rb"
run "cp ~/sites/startup_template/db/migrate/20130416101414_create_supermodels.rb ~/sites/#{@app_name}/db/migrate/20130416101414_create_supermodels.rb"
run "cp ~/sites/startup_template/db/migrate/20130417121717_create_tags.rb ~/sites/#{@app_name}/db/migrate/20130417121717_create_tags.rb"
run "cp ~/sites/startup_template/db/migrate/20130418121717_create_taggings.rb ~/sites/#{@app_name}/db/migrate/20130418121717_create_taggings.rb"
run "cp ~/sites/startup_template/db/migrate/20130307183748_create_user_roles.rb ~/sites/#{@app_name}/db/migrate/20130307183748_create_user_roles.rb"
run "cp ~/sites/startup_template/db/migrate/20130422115656_add_approved_to_users.rb ~/sites/#{@app_name}/db/migrate/20130422115656_add_approved_to_users.rb"


#rake all migrations
rake "db:migrate"


################
## app/models ##
################

run "mkdir app/services"
# services/describe.rb
run "touch app/services/describe.rb & cp ~/sites/startup_template/app/services/describe.rb ~/sites/#{@app_name}/app/services/describe.rb"

# ability.rb
run "touch app/models/ability.rb & cp ~/sites/startup_template/app/models/ability.rb ~/sites/#{@app_name}/app/models/ability.rb"
# announcement.rb
run "touch app/models/announcement.rb & cp ~/sites/startup_template/app/models/announcement.rb ~/sites/#{@app_name}/app/models/announcement.rb"
# blog.rb
run "touch app/models/blog.rb & cp ~/sites/startup_template/app/models/blog.rb ~/sites/#{@app_name}/app/models/blog.rb"
# comment.rb
run "touch app/models/comment.rb & cp ~/sites/startup_template/app/models/comment.rb ~/sites/#{@app_name}/app/models/comment.rb"
# event.rb
run "touch app/models/event.rb & cp ~/sites/startup_template/app/models/event.rb ~/sites/#{@app_name}/app/models/event.rb"
# link.rb
run "touch app/models/link.rb & cp ~/sites/startup_template/app/models/link.rb ~/sites/#{@app_name}/app/models/link.rb"
# links_page.rb
run "touch app/models/links_page.rb & cp ~/sites/startup_template/app/models/links_page.rb ~/sites/#{@app_name}/app/models/links_page.rb"
# page.rb
run "touch app/models/page.rb & cp ~/sites/startup_template/app/models/page.rb ~/sites/#{@app_name}/app/models/page.rb"
# page_partial.rb
run "touch app/models/page_partial.rb & cp ~/sites/startup_template/app/models/page_partial.rb ~/sites/#{@app_name}/app/models/page_partial.rb"
# partial.rb
run "touch app/models/partial.rb & cp ~/sites/startup_template/app/models/partial.rb ~/sites/#{@app_name}/app/models/partial.rb"
# profile.rb
run "touch app/models/profile.rb & cp ~/sites/startup_template/app/models/profile.rb ~/sites/#{@app_name}/app/models/profile.rb"
# role.rb
run "touch app/models/role.rb & cp ~/sites/startup_template/app/models/role.rb ~/sites/#{@app_name}/app/models/role.rb"
# status.rb
run "touch app/models/status.rb & cp ~/sites/startup_template/app/models/status.rb ~/sites/#{@app_name}/app/models/status.rb"
# supermodel.rb
run "touch app/models/supermodel.rb & cp ~/sites/startup_template/app/models/supermodel.rb ~/sites/#{@app_name}/app/models/supermodel.rb"
# tag.rb
run "touch app/models/tag.rb & cp ~/sites/startup_template/app/models/tag.rb ~/sites/#{@app_name}/app/models/tag.rb"
# tagging.rb
run "touch app/models/tagging.rb & cp ~/sites/startup_template/app/models/tagging.rb ~/sites/#{@app_name}/app/models/tagging.rb"

# user.rb
inject_into_file "app/models/user.rb", :after => "attr_accessible :email, :password, :password_confirmation, :remember_me\n" do <<-'RUBY'
	attr_accessible :first_name, :last_name, :role, :username, :approved
  attr_accessible :role_ids, :as => :admin
  has_and_belongs_to_many :roles
  before_create :setup_role
  ## acts_as_orderer

  def self.approved
    where(approved: true)
  end

  def self.not_approved
    where(approved: false)
  end

  def self.order_by_name
    order("last_name ASC")
  end

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
## app/assets/javascripts ##
############################

run "touch app/assets/javascripts/announcement.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/announcement.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/announcement.js.coffee"
run "touch app/assets/javascripts/blog.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/blog.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/blog.js.coffee"
run "touch app/assets/javascripts/event.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/event.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/event.js.coffee"
run "touch app/assets/javascripts/page.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/page.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/page.js.coffee"
run "touch app/assets/javascripts/static_page.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/static_page.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/static_page.js.coffee"
run "touch app/assets/javascripts/supermodel.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/supermodel.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/supermodel.js.coffee"
run "touch app/assets/javascripts/user.js.coffee && cp ~/sites/startup_template/app/assets/javascripts/user.js.coffee ~/sites/#{@app_name}/app/assets/javascripts/user.js.coffee"


############################
## app/assets/stylesheets ##
############################

run "touch app/assets/stylesheets/announcements.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/announcements.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/announcements.css.scss"
run "touch app/assets/stylesheets/blogs.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/blogs.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/blogs.css.scss"
run "touch app/assets/stylesheets/events.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/events.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/events.css.scss"
run "touch app/assets/stylesheets/scaffolds.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/scaffolds.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/scaffolds.css.scss"
run "touch app/assets/stylesheets/static_pages.css.scss && cp ~/sites/startup_template/app/assets/stylesheets/static_pages.css.scss ~/sites/#{@app_name}/app/assets/stylesheets/static_pages.css.scss"

#####################
## app/helpers ##
#####################

# application_helper.rb
run "cp ~/sites/startup_template/app/helpers/application_helper.rb ~/sites/#{@app_name}/app/helpers/application_helper.rb"

#####################
## app/controllers ##
#####################

# announcements_controller.rb
run "touch app/controllers/announcements_controller.rb & cp ~/sites/startup_template/app/controllers/announcements_controller.rb ~/sites/#{@app_name}/app/controllers/announcements_controller.rb"
# application_controller.rb
run "cp ~/sites/startup_template/app/controllers/application_controller.rb ~/sites/#{@app_name}/app/controllers/application_controller.rb"
# blogs_controller.rb
run "touch app/controllers/blogs_controller.rb & cp ~/sites/startup_template/app/controllers/blogs_controller.rb ~/sites/#{@app_name}/app/controllers/blogs_controller.rb"
# comments_controller.rb
run "touch app/controllers/comments_controller.rb & cp ~/sites/startup_template/app/controllers/comments_controller.rb ~/sites/#{@app_name}/app/controllers/comments_controller.rb"
# events_controller.rb
run "touch app/controllers/events_controller.rb & cp ~/sites/startup_template/app/controllers/events_controller.rb ~/sites/#{@app_name}/app/controllers/events_controller.rb"
# links_controller.rb
run "touch app/controllers/links_controller.rb & cp ~/sites/startup_template/app/controllers/links_controller.rb ~/sites/#{@app_name}/app/controllers/links_controller.rb"
# pages_controller.rb
run "touch app/controllers/pages_controller.rb & cp ~/sites/startup_template/app/controllers/pages_controller.rb ~/sites/#{@app_name}/app/controllers/pages_controller.rb"
# partials_controller.rb
run "touch app/controllers/partials_controller.rb & cp ~/sites/startup_template/app/controllers/partials_controller.rb ~/sites/#{@app_name}/app/controllers/partials_controller.rb"
# profiles_controller.rb
run "touch app/controllers/profiles_controller.rb & cp ~/sites/startup_template/app/controllers/profiles_controller.rb ~/sites/#{@app_name}/app/controllers/profiles_controller.rb"
# roles_controller.rb
run "touch app/controllers/roles_controller.rb & cp ~/sites/startup_template/app/controllers/roles_controller.rb ~/sites/#{@app_name}/app/controllers/roles_controller.rb"
# static_pages_controller.rb
run "touch app/controllers/static_pages_controller.rb & cp ~/sites/startup_template/app/controllers/static_pages_controller.rb ~/sites/#{@app_name}/app/controllers/static_pages_controller.rb"
# statuses_controller.rb
run "touch app/controllers/statuses_controller.rb & cp ~/sites/startup_template/app/controllers/statuses_controller.rb ~/sites/#{@app_name}/app/controllers/statuses_controller.rb"
# supermodels.rb
run "touch app/controllers/supermodels_controller.rb & cp ~/sites/startup_template/app/controllers/supermodels_controller.rb ~/sites/#{@app_name}/app/controllers/supermodels_controller.rb"
# users.rb
run "touch app/controllers/users_controller.rb & cp ~/sites/startup_template/app/controllers/users_controller.rb ~/sites/#{@app_name}/app/controllers/users_controller.rb"

#####################
## app/views ##
#####################

# announcements
run "mkdir app/views/announcements"
run "cp ~/sites/startup_template/app/views/announcements/_announcement.html.erb ~/sites/#{@app_name}/app/views/announcements/_announcement.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/_announcement_partial.html.erb ~/sites/#{@app_name}/app/views/announcements/_announcement_partial.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/_form.html.erb ~/sites/#{@app_name}/app/views/announcements/_form.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/destroy.js.erb ~/sites/#{@app_name}/app/views/announcements/destroy.js.erb"
run "cp ~/sites/startup_template/app/views/announcements/edit.html.erb ~/sites/#{@app_name}/app/views/announcements/edit.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/hide.js.erb ~/sites/#{@app_name}/app/views/announcements/hide.js.erb"
run "cp ~/sites/startup_template/app/views/announcements/index.html.erb ~/sites/#{@app_name}/app/views/announcements/index.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/new.html.erb ~/sites/#{@app_name}/app/views/announcements/new.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/show.html.erb ~/sites/#{@app_name}/app/views/announcements/show.html.erb"
run "cp ~/sites/startup_template/app/views/announcements/update.js.erb ~/sites/#{@app_name}/app/views/announcements/update.js.erb"

# blogs
run "mkdir app/views/blogs"
run "cp ~/sites/startup_template/app/views/blogs/_blog.html.erb ~/sites/#{@app_name}/app/views/blogs/_blog.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/_blog_partial.html.erb ~/sites/#{@app_name}/app/views/blogs/_blog_partial.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/_form.html.erb ~/sites/#{@app_name}/app/views/blogs/_form.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/edit.html.erb ~/sites/#{@app_name}/app/views/blogs/edit.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/index.html.erb ~/sites/#{@app_name}/app/views/blogs/index.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/new.html.erb ~/sites/#{@app_name}/app/views/blogs/new.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/show.html.erb ~/sites/#{@app_name}/app/views/blogs/show.html.erb"
run "cp ~/sites/startup_template/app/views/blogs/update.js.erb ~/sites/#{@app_name}/app/views/blogs/update.js.erb"

# comments
run "mkdir app/views/comments"
run "cp ~/sites/startup_template/app/views/comments/_comment.html.erb ~/sites/#{@app_name}/app/views/comments/_comment.html.erb"
run "cp ~/sites/startup_template/app/views/comments/_form.html.erb ~/sites/#{@app_name}/app/views/comments/_form.html.erb"
run "cp ~/sites/startup_template/app/views/comments/edit.html.erb ~/sites/#{@app_name}/app/views/comments/edit.html.erb"
run "cp ~/sites/startup_template/app/views/comments/index.html.erb ~/sites/#{@app_name}/app/views/comments/index.html.erb"
run "cp ~/sites/startup_template/app/views/comments/new.html.erb ~/sites/#{@app_name}/app/views/comments/new.html.erb"
run "cp ~/sites/startup_template/app/views/comments/show.html.erb ~/sites/#{@app_name}/app/views/comments/show.html.erb"

# events
run "mkdir app/views/events"
run "cp ~/sites/startup_template/app/views/events/_event.html.erb ~/sites/#{@app_name}/app/views/events/_event.html.erb"
run "cp ~/sites/startup_template/app/views/events/_event_partial.html.erb ~/sites/#{@app_name}/app/views/events/_event_partial.html.erb"
run "cp ~/sites/startup_template/app/views/events/_form.html.erb ~/sites/#{@app_name}/app/views/events/_form.html.erb"
run "cp ~/sites/startup_template/app/views/events/edit.html.erb ~/sites/#{@app_name}/app/views/events/edit.html.erb"
run "cp ~/sites/startup_template/app/views/events/index.html.erb ~/sites/#{@app_name}/app/views/events/index.html.erb"
run "cp ~/sites/startup_template/app/views/events/new.html.erb ~/sites/#{@app_name}/app/views/events/new.html.erb"
run "cp ~/sites/startup_template/app/views/events/show.html.erb ~/sites/#{@app_name}/app/views/events/show.html.erb"
run "cp ~/sites/startup_template/app/views/events/update.js.erb ~/sites/#{@app_name}/app/views/events/update.js.erb"

# layouts
run "cp ~/sites/startup_template/app/views/layouts/application.html.erb ~/sites/#{@app_name}/app/views/layouts/application.html.erb"
run "cp ~/sites/startup_template/app/views/layouts/dashboard.html.erb ~/sites/#{@app_name}/app/views/layouts/dashboard.html.erb"

# links
run "mkdir app/views/links"
run "cp ~/sites/startup_template/app/views/links/_form.html.erb ~/sites/#{@app_name}/app/views/links/_form.html.erb"
run "cp ~/sites/startup_template/app/views/links/edit.html.erb ~/sites/#{@app_name}/app/views/links/edit.html.erb"
run "cp ~/sites/startup_template/app/views/links/index.html.erb ~/sites/#{@app_name}/app/views/links/index.html.erb"
run "cp ~/sites/startup_template/app/views/links/new.html.erb ~/sites/#{@app_name}/app/views/links/new.html.erb"
run "cp ~/sites/startup_template/app/views/links/show.html.erb ~/sites/#{@app_name}/app/views/links/show.html.erb"

# pages
run "mkdir app/views/pages"
run "cp ~/sites/startup_template/app/views/pages/_form.html.erb ~/sites/#{@app_name}/app/views/pages/_form.html.erb"
run "cp ~/sites/startup_template/app/views/pages/_page.html.erb ~/sites/#{@app_name}/app/views/pages/_page.html.erb"
run "cp ~/sites/startup_template/app/views/pages/edit.html.erb ~/sites/#{@app_name}/app/views/pages/edit.html.erb"
run "cp ~/sites/startup_template/app/views/pages/index.html.erb ~/sites/#{@app_name}/app/views/pages/index.html.erb"
run "cp ~/sites/startup_template/app/views/pages/new.html.erb ~/sites/#{@app_name}/app/views/pages/new.html.erb"
run "cp ~/sites/startup_template/app/views/pages/show.html.erb ~/sites/#{@app_name}/app/views/pages/show.html.erb"
run "cp ~/sites/startup_template/app/views/pages/update.js.erb ~/sites/#{@app_name}/app/views/pages/update.js.erb"

# partials
run "mkdir app/views/partials"
run "cp ~/sites/startup_template/app/views/partials/_form.html.erb ~/sites/#{@app_name}/app/views/partials/_form.html.erb"
run "cp ~/sites/startup_template/app/views/partials/edit.html.erb ~/sites/#{@app_name}/app/views/partials/edit.html.erb"
run "cp ~/sites/startup_template/app/views/partials/index.html.erb ~/sites/#{@app_name}/app/views/partials/index.html.erb"
run "cp ~/sites/startup_template/app/views/partials/new.html.erb ~/sites/#{@app_name}/app/views/partials/new.html.erb"
run "cp ~/sites/startup_template/app/views/partials/show.html.erb ~/sites/#{@app_name}/app/views/partials/show.html.erb"

# profiles
run "mkdir app/views/profiles"
run "cp ~/sites/startup_template/app/views/profiles/_form.html.erb ~/sites/#{@app_name}/app/views/profiles/_form.html.erb"
run "cp ~/sites/startup_template/app/views/profiles/edit.html.erb ~/sites/#{@app_name}/app/views/profiles/edit.html.erb"
run "cp ~/sites/startup_template/app/views/profiles/index.html.erb ~/sites/#{@app_name}/app/views/profiles/index.html.erb"
run "cp ~/sites/startup_template/app/views/profiles/new.html.erb ~/sites/#{@app_name}/app/views/profiles/new.html.erb"
run "cp ~/sites/startup_template/app/views/profiles/show.html.erb ~/sites/#{@app_name}/app/views/profiles/show.html.erb"

# roles
run "mkdir app/views/roles"
run "cp ~/sites/startup_template/app/views/roles/_form.html.erb ~/sites/#{@app_name}/app/views/roles/_form.html.erb"
run "cp ~/sites/startup_template/app/views/roles/edit.html.erb ~/sites/#{@app_name}/app/views/roles/edit.html.erb"
run "cp ~/sites/startup_template/app/views/roles/index.html.erb ~/sites/#{@app_name}/app/views/roles/index.html.erb"
run "cp ~/sites/startup_template/app/views/roles/new.html.erb ~/sites/#{@app_name}/app/views/roles/new.html.erb"
run "cp ~/sites/startup_template/app/views/roles/show.html.erb ~/sites/#{@app_name}/app/views/roles/show.html.erb"

# shared
run "mkdir app/views/shared"
run "cp ~/sites/startup_template/app/views/shared/_announcements.html.erb ~/sites/#{@app_name}/app/views/shared/_announcements.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_authentication.html.erb ~/sites/#{@app_name}/app/views/shared/_authentication.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_crud_btns.html.erb ~/sites/#{@app_name}/app/views/shared/_crud_btns.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_crud_btns_without_view.html.erb ~/sites/#{@app_name}/app/views/shared/_crud_btns_without_view.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_errors.html.erb ~/sites/#{@app_name}/app/views/shared/_errors.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_flash.html.erb ~/sites/#{@app_name}/app/views/shared/_flash.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_footer.html.erb ~/sites/#{@app_name}/app/views/shared/_footer.html.erb"
run "cp ~/sites/startup_template/app/views/shared/_header.html.erb ~/sites/#{@app_name}/app/views/shared/_header.html.erb"
run "cp ~/sites/startup_template/app/views/shared/quick_partial_view.html.erb ~/sites/#{@app_name}/app/views/shared/quick_partial_view.html.erb"

#static_pages
run "mkdir app/views/static_pages"
run "cp ~/sites/startup_template/app/views/static_pages/dashboard.html.erb ~/sites/#{@app_name}/app/views/static_pages/dashboard.html.erb"
run "cp ~/sites/startup_template/app/views/static_pages/_table_list.html.erb ~/sites/#{@app_name}/app/views/static_pages/_table_list.html.erb"

#supermodels
run "mkdir app/views/supermodels/"
run "cp ~/sites/startup_template/app/views/supermodels/_form.html.erb ~/sites/#{@app_name}/app/views/supermodels/_form.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/_supermodel.html.erb ~/sites/#{@app_name}/app/views/supermodels/_supermodel.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/edit.html.erb ~/sites/#{@app_name}/app/views/supermodels/edit.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/index.html.erb ~/sites/#{@app_name}/app/views/supermodels/index.html.erb"
run "cp ~/sites/startup_template/app/views/supermodels/update.js.erb ~/sites/#{@app_name}/app/views/supermodels/update.js.erb"

#users
run "mkdir app/views/users/"
run "cp ~/sites/startup_template/app/views/users/_choose_role.html.erb ~/sites/#{@app_name}/app/views/users/_choose_role.html.erb"
run "cp ~/sites/startup_template/app/views/users/_form.html.erb ~/sites/#{@app_name}/app/views/users/_form.html.erb"
run "cp ~/sites/startup_template/app/views/users/_user.html.erb ~/sites/#{@app_name}/app/views/users/_user.html.erb"
run "cp ~/sites/startup_template/app/views/users/edit.html.erb ~/sites/#{@app_name}/app/views/users/edit.html.erb"
run "cp ~/sites/startup_template/app/views/users/index.html.erb ~/sites/#{@app_name}/app/views/users/index.html.erb"
run "cp ~/sites/startup_template/app/views/users/update.js.erb ~/sites/#{@app_name}/app/views/users/update.js.erb"

###############
## lib ##
###############
run "cp ~/sites/startup_template/lib/arrays.rb ~/sites/#{@app_name}/lib/arrays.rb"

###############
## lib/tasks ##
###############

run "cp ~/sites/startup_template/lib/tasks/create_links.rake ~/sites/#{@app_name}/lib/tasks/create_links.rake"
run "cp ~/sites/startup_template/lib/tasks/create_monarchAdmins.rake ~/sites/#{@app_name}/lib/tasks/create_monarchAdmins.rake"
run "cp ~/sites/startup_template/lib/tasks/create_roles.rake ~/sites/#{@app_name}/lib/tasks/create_roles.rake"
run "cp ~/sites/startup_template/lib/tasks/build_all.rake ~/sites/#{@app_name}/lib/tasks/build_all.rake"
run "cp ~/sites/startup_template/lib/my_date_formats.rb ~/sites/#{@app_name}/lib/my_date_formats.rb"

###################
## assets/images ##
###################
run "cp ~/sites/startup_template/app/assets/images/sidebar.png ~/sites/#{@app_name}/app/assets/images/sidebar.png"
run "cp ~/sites/startup_template/app/assets/images/black_opac.png ~/sites/#{@app_name}/app/assets/images/black_opac.png"
run "cp ~/sites/startup_template/app/assets/images/gray_back2.jpg ~/sites/#{@app_name}/app/assets/images/gray_back2.jpg"
run "cp ~/sites/startup_template/app/assets/images/crud.png ~/sites/#{@app_name}/app/assets/images/icons.png"
run "cp ~/sites/startup_template/app/assets/images/green.png ~/sites/#{@app_name}/app/assets/images/green.png"
run "cp ~/sites/startup_template/app/assets/images/menu_shadow.png ~/sites/#{@app_name}/app/assets/images/menu_shadow.png"












