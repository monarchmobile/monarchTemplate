startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/startup_template.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:

rails new <app_name> --database=postgresql -m ~/sites/startup_template/template.rb


// instruction to share this and other apps with team members // <br />
git fetch <br />
git merge orgin/master < n/>

git checkout -b whatever
---- add changes --
git add .
git commit -m “first commit”
git push origin whatever

git checkout master
git fetch
git merge origin/master
git merge whatever
git push
