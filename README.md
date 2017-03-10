## Installation Instructions

```
    git clone https://github.com/sdfb/sdfb.git
    gem install bundler
    bundle install
```

At this point, you'll need to start up PostgreSQL manually.

```
    rake db:setup
```


*(You will need to copy `Procfile.development.example` to `Procfile.development` and modify it to reflect the way that you start up your instance of the database.*)

## Starting Up the Server (in Development Mode)

```
    foreman start --procfile=Procfile.development
```

-------

*(Everything below this line is from the original readme, kept for posterity until we're sure that everything mentioned is captured somewhere important.)*

## HEROKU SETUP TO PUSH TO EITHER THE SANDBOX OR THE LIVE HEROKU VERSION
1. Following these instructions, download the Heroku toolbelt so you can run from the command line
2. In the command line, run heroku login
3. Login with the SixDegreesFrancisBacon@gmail.com account (information on the Account Info google doc)

## TO PUSH TO LIVE VERSION OF HEROKU
*Only do this if it's working on the sandbox
1. From the sdfb directory on your machine, run heroku git:remote -a sixdegfrancisbacon
2. Make sure all local changes are working
3. Commit and push the changes to the SDFB repo on github
  3a. View the changes you are making with "git status" 
  3b. Add the changes you are making to staging with "git add ." or if you are adding new files too then "git add -A"
  3b. Check that all files are staged running "git status" again. If there are any red issues then consider usuing "git add -A" instead of just "git add ."
  3c. Commit your staged changes with a message using 'git commit -m "this is a sample message"'
  3d. Check that all your stages have been committed with "git status"
  3e. pull other developer's changes with "git pull". Make sure that there are no errors or conflicts with the pull. if there are conflicts you need to go into the file that has the conflict and resolve it and then commit the changes you made to do that (steps 3b to 3d)
  3f. test that everything works locally after you pulled the other developer's changes. Don't just check that your code works, check everything on the app but specifically...
    i. the visualization
    ii. the visualization's searches
    iii. that you can add a new person record 
    iv. that you can edit an existing person record
    v. that you can add a relationship for the new person and edit the certainty of the relationship with a working slider
    vi. that the group search works (autocomplete search should work)
    vii. that export works
  3g. Compile assets with "rake assets:precompile" then commit (steps 3b to 3d)
  3h. Push your changes "git push"
4. push your changes on heroku with "git push heroku master"
5. if you made changes to to the routes folder run "heroku run rake routes"
6. if you made changes to to the datebase file by adding migrations run "heroku run db:migrate"

## TO PUSH TO THE SANDBOX 
1. Switch to the sandbox repository (see step 1 of the TO PUSH TO LIVE VERSION OF HEROKU for details on how to push live). From the sdfb directory on your machine, run "heroku git:remote -a sdfb2"
2. Follow "TO PUSH TO LIVE VERSION OF HEROKU" section steps 3-6

## POPULATING HEROKU
To run any script for heroku you need to add "heroku run" before "rake". For example, to migrate run "heroku run rake db:migrate" in the command line.
If populating the entire database you can run the file herokupop.sh which will run all the scripts. There are a bunch of commands:
    
    ## To populate everything:

    ```
    populate.sh
    ```

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
    
    # Populate start and end dates (only need to do this if you originally populated relationships before May 1, 2015)
    rake db:populate_rel_start_end_date_100000001_100010000
    rake db:populate_rel_start_end_date_100010001_100020000
    rake db:populate_rel_start_end_date_100020001_100030000
    rake db:populate_rel_start_end_date_100030001_100040000
    rake db:populate_rel_start_end_date_100040001_100050000
    rake db:populate_rel_start_end_date_100050001_100060000
    rake db:populate_rel_start_end_date_100060001_100070000
    rake db:populate_rel_start_end_date_100070001_100080000
    rake db:populate_rel_start_end_date_100080001_100090000
    rake db:populate_rel_start_end_date_100090001_100100000
    rake db:populate_rel_start_end_date_100100001_100110000
    rake db:populate_rel_start_end_date_100110001_100120000
    rake db:populate_rel_start_end_date_100120001_100130000
    rake db:populate_rel_start_end_date_100130001_100140000
    rake db:populate_rel_start_end_date_100140001_100150000
    rake db:populate_rel_start_end_date_100150001_100160000
    rake db:populate_rel_start_end_date_100160001_100170000
    rake db:populate_rel_start_end_date_100170001_100180000


    ## Populate the first met records. You don't have to do this if you populated the relationships or start and end dates after July 6th
    rake db:populate_rel_met_record_100000001_100010000
    rake db:populate_rel_met_record_100010001_100020000
    rake db:populate_rel_met_record_100020001_100030000
    rake db:populate_rel_met_record_100030001_100040000
    rake db:populate_rel_met_record_100040001_100050000
    rake db:populate_rel_met_record_100050001_100060000
    rake db:populate_rel_met_record_100060001_100070000
    rake db:populate_rel_met_record_100070001_100080000
    rake db:populate_rel_met_record_100080001_100090000
    rake db:populate_rel_met_record_100090001_100100000
    rake db:populate_rel_met_record_100100001_100110000
    rake db:populate_rel_met_record_100110001_100120000
    rake db:populate_rel_met_record_100120001_100130000
    rake db:populate_rel_met_record_100130001_100140000
    rake db:populate_rel_met_record_100140001_100150000
    rake db:populate_rel_met_record_100150001_100160000
    rake db:populate_rel_met_record_100160001_100170000
    rake db:populate_rel_met_record_100170001_100180000

    ## IMPORTANT NOTES ON POPULATING:
    1. You must only run the following if updating people populated prior to March 12, 2015
        rake db:populate_rel_sum
    2. To populate the first time, you must comment out the following before populating (then comment back in after you are done):
        In app>models>person.rb, "validates_presence_of :display_name"



## ENTITY NAME CHANGES
Note that user_group_contribs is referred to as group notes

User_rel_contribs is referred to as relationship type assignments and has more than just relationship notes because the user can assign relationship types to a relationship there.

User_person_contribs is referred to as person/people notes

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

s.
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

## To run the server locally:

```
Start Postgres
type "rails s" without the quotes into the terminal
navigate to http://localhost:3000/
end this process by sending "Ctrl-C" in terminal
```

## Brakeman as of 7/27/15
+SUMMARY+

+-------------------+--------+
| Scanned/Reported  | Total  |
+-------------------+--------+
| Controllers       | 20     |
| Models            | 16     |
| Templates         | 179    |
| Errors            | 1      |
| Security Warnings | 17 (1) |
+-------------------+--------+

+----------------------------+-------+
| Warning Type               | Total |
+----------------------------+-------+
| Cross Site Scripting       | 1     |
| Cross-Site Request Forgery | 1     |
| Denial of Service          | 1     |
| Mass Assignment            | 12    |
| SQL Injection              | 1     |
| Session Setting            | 1     |
+----------------------------+-------+
+Errors+
+-------------------------------------------------------------------------------------------------------------------------------------+--------------->>
| Error                                                                                                                               | Location      >>
+-------------------------------------------------------------------------------------------------------------------------------------+--------------->>
| /Users/katarinashaw/Documents/sdfb/app/views/relationships/all_rels_for_person.html.erb:29 :: parse error on value ["do", 29] (kDO) | Could not pars>>
+-------------------------------------------------------------------------------------------------------------------------------------+--------------->>


+SECURITY WARNINGS+

+------------+--------+------------------+----------------------+------------------------------------------------------------------------------------->>
| Confidence | Class  | Method           | Warning Type         | Message                                                                             >>
+------------+--------+------------------+----------------------+------------------------------------------------------------------------------------->>
| High       |        |                  | Session Setting      | Session secret should not be included in version control near line 7                >>
| Medium     |        |                  | Cross Site Scripting | Rails 4.1.8 does not encode JSON keys (CVE-2015-3226). Upgrade to Rails version 4.1.>>
| Medium     |        |                  | Denial of Service    | Rails 4.1.8 is vulnerable to denial of service via XML parsing (CVE-2015-3227). Upgr>>
| Medium     | Person | first_degree_for | SQL Injection        | Possible SQL injection near line 43: select("people.*").joins("join relationships r1>>
+------------+--------+------------------+----------------------+------------------------------------------------------------------------------------->>



Controller Warnings:

+------------+-----------------------+----------------------------+-------------------------------------------------------------------+
| Confidence | Controller            | Warning Type               | Message                                                           |
+------------+-----------------------+----------------------------+-------------------------------------------------------------------+
| Medium     | ApplicationController | Cross-Site Request Forgery | protect_from_forgery should be configured with 'with: :exception' |
+------------+-----------------------+----------------------------+-------------------------------------------------------------------+


Model Warnings:

+------------+-------------------+-----------------+------------------------------------------------------------------------------------------+
| Confidence | Model             | Warning Type    | Message                                                                                  |
+------------+-------------------+-----------------+------------------------------------------------------------------------------------------+
| Weak       | Flag              | Mass Assignment | Potentially dangerous attribute available for mass assignment: :assoc_object_id          |
| Weak       | GroupAssignment   | Mass Assignment | Potentially dangerous attribute available for mass assignment: :group_id                 |
| Weak       | GroupAssignment   | Mass Assignment | Potentially dangerous attribute available for mass assignment: :person_id                |
| Weak       | GroupCatAssign    | Mass Assignment | Potentially dangerous attribute available for mass assignment: :group_category_id        |
| Weak       | GroupCatAssign    | Mass Assignment | Potentially dangerous attribute available for mass assignment: :group_id                 |
| Weak       | Person            | Mass Assignment | Potentially dangerous attribute available for mass assignment: :odnb_id                  |
| Weak       | RelCatAssign      | Mass Assignment | Potentially dangerous attribute available for mass assignment: :relationship_category_id |
| Weak       | RelCatAssign      | Mass Assignment | Potentially dangerous attribute available for mass assignment: :relationship_type_id     |
| Weak       | UserGroupContrib  | Mass Assignment | Potentially dangerous attribute available for mass assignment: :group_id                 |
| Weak       | UserPersonContrib | Mass Assignment | Potentially dangerous attribute available for mass assignment: :person_id                |
| Weak       | UserRelContrib    | Mass Assignment | Potentially dangerous attribute available for mass assignment: :relationship_id          |
| Weak       | UserRelContrib    | Mass Assignment | Potentially dangerous attribute available for mass assignment: :relationship_type_id     |
+------------+-------------------+-----------------+------------------------------------------------------------------------------------------+


