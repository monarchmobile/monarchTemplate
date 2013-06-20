startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/#########.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:


=======
rails new new_app_name --database=postgresql -m ~/sites/startup_template/template.rb

<<<<<<< HEAD
MonarchTemplate.rb is the template file that installs the template for each new monarch rails app.
=======
<br />
// instruction to share this and other apps with team members // <br />
git fetch <br />
git merge orgin/master <br /> <br />

git checkout -b branch_name <br />
---- add changes -- <br />
  git add . <br />
  git commit -m “first commit” <br />
  git push origin  branch_name <br /> <br />

git checkout master <br />
git fetch <br />
git merge origin/master <br />
git merge  branch_name <br />
git push <br />
>>>>>>> origin/master

// add to gemfile //<br />
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end
>>>>>>> origin/master
