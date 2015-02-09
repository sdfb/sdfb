## To prepare database by creating/clearing it:

```
rake db:drop (if database is already created)
rake db:create
rake db:migrate
```


## To populate this file:

```
rake db:generate_data
rake db:populate_pr
rake db:populate_groups
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
