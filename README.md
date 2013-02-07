startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/startup_template.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:

rails new <app_name> --database=postgresql -m ~/sites/startup_template/template.rb
