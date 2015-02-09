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
rake db:populate_rels_2_20000
rake db:populate_rels_20001_40000
rake db:populate_rels_40001_60000
rake db:populate_rels_60001_80000
rake db:populate_rels_80001_100000
rake db:populate_rels_100001_120000
rake db:populate_rels_120001_140000
rake db:populate_rels_140001_160000
rake db:populate_rels_160001_170542
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