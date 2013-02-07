startup_template
================

Get a copy of the template:

git clone git@github.com:monarchmobile/startup_template.git ~/sites/startup_template

Create a new Rails application as normal, specifying the path to the template script with the -m flag:

rails new app_name --database=postgresql -m ~/sites/startup_template/template.rb

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
