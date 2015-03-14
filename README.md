## TO PUSH TO HEROKU
1. Following these instructions, download the Heroku toolbelt so you can run from the command line
2. In the command line, run heroku login
3. Login with the sixdegfrancsbacon@gmail.com account (information on the Account Info google doc)
4. From the sdfb directory on your machine, run heroku git:remote -a sixdegfrancisbacon
5. Make sure all local changes are working
6. Commit and push the changes to Katarina's sdfb repo
7. Run git push heroku master
8. If making changes to js or css, run rake assets:precompile, then commit and push again before running git push heroku master

## To set up rails:
```
Follow this tutorial: http://rubyonrails.org/download/
And install the Postgres database at: http://postgresapp.com/
First time: To run the files cloned from Github and populate the database write the commands for the first time:
install software plugins specific to the app:
bundle install
```

## To prepare database by creating/clearing it:

```
rake db:drop (if database is already created)
rake db:create
rake db:migrate
rake routes 
```

## To populate everything:

```
populate.sh
```


## To populate this file:

```
rake db:populate_people
rake db:populate_groups
rake db:populate_people_genders
rake db:populate_group_cats
rake db:populate_rel_cats
rake db:populate_rel_types
rake db:populate_rel_cat_assigns
rake db:populate_group_cat_assigns
rake db:populate_people_display_names
rake db:populate_people_search_names_all
rake db:populate_rels_2_20000
rake db:populate_rels_20001_40000
rake db:populate_rels_40001_60000
rake db:populate_rels_60001_80000
rake db:populate_rels_80001_100000
rake db:populate_rels_100001_120000
rake db:populate_rels_120001_140000
rake db:populate_rels_140001_160000
rake db:populate_rels_160001_170542
rake db:populate_user_rel_contribs_samples
rake db:populate_people_display_names
rake db:populate_rel_list
```

## To run the server locally:

```
Start Postgres
type "rails s" without the quotes into the terminal
navigate to http://localhost:3000/
end this process by sending "Ctrl-C" in terminal
```


TODO:
-redirect when a user does not have access to a page.
-edit the forms (choose from user names) and validations
-edit the views to display names
---------
-create accordian
-create search using two names
-create search using one name w/ filters
-create search using group
-create search using two groups
