

assets
	images
	javascripts
	stylesheets

controllers
	application_controller
	blog_controller
	comments_controller
	profiles_controller
	links_controller
	pages_controller
	products_controller
	static_pages_controller
	supermodels_controller
	users_controller

helpers
	application_helper

mailers
	membership_mailer

models
	ckeditor
	ability
	blog
	comment
	profile
	link
	link_page
	page
	product
	role
	supermodel
	tag
	tagging
	user/devise

uploaders
	ckeditor(figure out which one)

views
	blogs
	comments
	profiles
	devise
	layouts
	pages
	products
	shared
	static_pages
	supermodels

config
	environments
		both
	initializers 
		a ton
	application.rb
	application.yml
	database.yml
	routes

db
	migrate

lib
	arrays
	tasks

script ?

gitignore

gemfile
	source 'https://rubygems.org'

	gem 'rails', '3.2.8'
	 :git => 'git://github.com/rails/rails.git'

	gem 'pg'

	group :assets do
	  gem 'sass-rails',   '~> 3.2.3'
	  gem 'coffee-rails', '~> 3.2.1'
	  gem 'uglifier', '>= 1.0.3'
	end

	group :development do
	  gem 'better_errors'
	  gem 'binding_of_caller'
	  gem 'meta_request'
	end

	gem 'devise'
	gem 'cancan'
	gem 'rails_admin'
	gem 'piggybak'
	gem "piggybak_taxonomy", '0.0.7'
	gem "piggybak_variants", '0.0.13'
	gem "jquery-ui-rails", :group => :assets
	gem 'jquery-rails'
	gem "thin"
	gem 'rmagick', '2.13.2', :git=>'http://github.com/rmagick/rmagick.git'
	gem "carrierwave"
	gem "ckeditor"
	gem "mini_magick"
	gem 'friendly_id'
	gem 'fog'
	gem 'client_side_validations'

uploader, need to integrate with amazon, ie. 'fog'
user model 
	roles
lib/ tasks
	set up new user with admin or superadmin priv


javascripts
	//= require rails.validations 
stylesheets
	blog.css.scss
	comments.css.scss
outpouring
	take stylesheets/admin and delete folder, then test


blogs						30
comments 				45
users 					1
tweet form dashboard
push announcements to all clients into dashboard
supermodel ajaxify checkbox in index			1

checklist model for things to work on
	Page/Design House	Task	Issue to be resolved	Person Assigned	Estimated Date of Completion	Initial Comment
	shows up in backend only
users
	not approved
	approved
	set roles for users


events
blogs
comments
tags

scheduling pages, announcements, articles, events
	set dates pretty
	run a task to activate dates to go live or expire

get tweets, facebook, newsletter and announcements from monarch

initiate tweets and facebook from dashboard

learn to schedule page publish
add ckeditor
articles
comments
tags
events

heroku run rake db:migrate --remote staging
heroku run rake db:create_statuses --remote staging
Link.find_by_location("no_link").delete
heroku restart


#164 cron jobs
	erase guest each morning at 2am
# users 
	signin -> go to waiting to be approved queue
	two lists in user index
		waiting to be approved
		approved
			divided by roles
# show page, events, blogs, annoucement on sheduled date


announcement date on index reversting to strange form
blog event date not pulling on on first click
get announcements to work

4/22/13 1:03pm
 config added gem

announcment form
choose state
draft 
schedule 
publish

current state below message, and not date choices yet
if schedule, show date, other than than, hide dates
change to "shedule" in drop down
"update" button should change to select dropdown choices
 


