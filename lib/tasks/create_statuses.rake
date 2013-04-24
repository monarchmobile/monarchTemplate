namespace :db do 
	desc "create statuses" 
	task :create_statuses => :environment do 	
		Status.create(status_name: "draft")
		Status.create(status_name: "scheduled")
		Status.create(status_name: "published")
	end
end