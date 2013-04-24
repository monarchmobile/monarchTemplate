namespace :db do 
	desc "create roles" 
	task :create_roles => :environment do 	
		Role.create(name: "SuperAdmin")
		Role.create(name: "Admin")
		Role.create(name: "Moderator")
		Role.create(name: "Guest")
	end 
end