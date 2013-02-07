startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/startup_template.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:

rails new <app_name> --database=postgresql -m ~/sites/startup_template/template.rb


// instruction to share this and other apps with team members // <br />
git fetch <br />
git merge orgin/master <br /> <br />

git checkout -b whatever <br />
---- add changes -- <br />
  git add . <br />
  git commit -m “first commit” <br />
  git push origin whatever <br /> <br />

git checkout master <br />
git fetch <br />
git merge origin/master <br />
git merge whatever <br />
git push <br />
