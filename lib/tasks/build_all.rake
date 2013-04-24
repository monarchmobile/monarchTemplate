namespace :start do 
	desc "create roles" 
	task :create_roles => :environment do 	
		Role.create(name: "SuperAdmin")
		Role.create(name: "Admin")
		Role.create(name: "Moderator")
		Role.create(name: "Guest")
	end 

	desc "permission team members for SuperAdmin status"
	task :create_monarchAdmins => :environment do
		super_admin = Role.find_by_name("SuperAdmin")
		admin = Role.find_by_name("Admin")
		User.create(first_name: 'Rodman', last_name: 'Henley', email: 'rodmanhe@hotmail.com', password: 'admin000')
		rod = User.find_by_email("rodmanhe@hotmail.com")
		rod.role_ids=[admin.id, super_admin.id]
		User.create(first_name: 'Andrew', last_name: 'Gross', email: 'monarchmobile@gmail.com', password: 'admin000')
		andrew = User.find_by_email("monarchmobile@gmail.com")
		andrew.role_ids=[admin.id, super_admin.id]
	end

	desc "create links" 
	task :create_links => :environment do 	
		Link.create(location: "top_link")
		Link.create(location: "side_link")
	end 

	desc "create statuses" 
	task :create_statuses => :environment do 	
		Status.create(status_name: "draft")
		Status.create(status_name: "scheduled")
		Status.create(status_name: "published")
	end

	desc "create pages"
	task :create_pages => :environment do
		Page.create(title: "home", content: "This is your home page", current_state: 3)
		Page.create(title: "about", content: "this is your about page", current_state: 1)
	end

	desc "create partials"
	task :create_partials => :environment do
		Partial.create(name: "Announcement", position: 1)
		Partial.create(name: "Blog", position: 2)
		Partial.create(name: "Event", position: 3)
	end

	desc "build all" 
	task :build_all => [:create_roles, :create_monarchAdmins, :create_links, :create_statuses, :create_pages, :create_partials] do
		puts "Roles, Logins(Rod and Andrew), Links, & statuses created"
	end

end