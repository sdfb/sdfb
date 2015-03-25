## TO PUSH TO HEROKU
1. Following these instructions, download the Heroku toolbelt so you can run from the command line
2. In the command line, run heroku login
3. Login with the SixDegreesFrancisBacon@gmail.com account (information on the Account Info google doc)
4. From the sdfb directory on your machine, run heroku git:remote -a sixdegfrancisbacon
5. Make sure all local changes are working
6. Commit and push the changes to Katarina's sdfb repo
7. Run git push heroku master
8. If making changes to js or css, run rake assets:precompile, then commit and push again before running git push heroku master


## POPULATING HEROKU
To run any script for heroku you need to add "heroku run" before "rake". For example, to migrate run "heroku run rake db:migrate" in the command line.
If populating the entire database you can run the file herokupop.sh which will run all the scripts.



## Status
Had to roll back populate changes because there 
is more logic in the models than I thought.
 
Currently, the nodes and relationships are 
individually read from the tsv 
files, then fields are added, one by one 
they are inserted into Postgres. Each record is 
then passed through to the rails controllers 
where it performs around 250,000 queries each of 
which result in K update operations to the text 
field that contains "rel_sum". This text field 
contains aggregated Ids of all of the nodes that 
each person has references to in the 
relationships table to. The array of node ids is
serialized to a single string and each person is 
then updated with the field "rel_sum".Every time 
a person is queried, the field is parsed and 
serialized back into an array, changed, and then 
converted back into a string and stored.


## Alternatively, I think the query below runs in O(n), 
I'm also not sompletely sure the way above converges.
```sql
 SELECT t1.person1_index AS pid, 
   ARRAY(( 
    SELECT t2.person2_index 
    FROM relationships t2 
    WHERE t2.person1_index = t1.person1_index
   )) AS rels 
FROM relationships t1 
GROUP BY t1.person1_index;
```
And if we must store this field, 
this runs almost as fast.
```sql
UPDATE people AS p SET rel_sum = t3.rels FROM (
    SELECT t1.person1_index as pid, 
    ARRAY(( 
       SELECT t2.person2_index 
       FROM relationships t2 
       WHERE t2.person1_index = t1.person1_index
    )) AS rels 
    FROM relationships t1 
    GROUP BY t1.person1_index
 ) t3 WHERE p.id = t3.pid;
```

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


## To populate this file run the following commands in order:

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
rake db:populate_rel_start_end_date_20001_20367
rake db:populate_rel_start_end_date_20368_40000
rake db:populate_rel_start_end_date_50293_60000**didnt work
rake db:populate_rel_start_end_date_60917_80000**
rake db:populate_rel_start_end_date_82014_88072
rake db:populate_rel_start_end_date_88073_100000***
rake db:populate_rel_start_end_date_101033_120000***100101035
***

## IMPORTANT NOTES ON POPULATING:
1. You must only run the following if updating people populated prior to March 12, 2015
    rake db:populate_rel_sum
2. To populate the first time, you must comment out the following before populating (then comment back in after you are done):
    In app>models>person.rb, "validates_presence_of :display_name"

3. Manually enter start and end dates for relationships 100007211, 100003942, and 100006369, 100009301, 100009302, 100009303, 100017191, 100009305, 100019846, 100009361, 100009362, 100019847, 100019846, 100019847, 100020367, 100050292, 100060915, 100101032, 100022939, 100088072, 100101032, 100093012

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
