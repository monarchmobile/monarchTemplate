namespace :db do 
	desc "create links" 
	task :create_links => :environment do 	
		Link.create(location: "top_link")
		Link.create(location: "side_link")
		Link.create(location: "no_link")
	end 
end