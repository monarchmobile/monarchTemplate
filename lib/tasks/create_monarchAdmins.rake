namespace :db do
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
end