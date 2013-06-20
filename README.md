startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/#########.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:


=======
rails new new_app_name --database=postgresql -m ~/sites/startup_template/template.rb

MonarchTemplate.rb is the template file that installs the template for each new monarch rails app.
