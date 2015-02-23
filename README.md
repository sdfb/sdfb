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

## To prepare database by creating/clearing it:

```
rake db:drop (if database is already created)
rake db:create
rake db:migrate
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
rake routes
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
