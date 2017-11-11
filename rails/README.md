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

## Starting Up the Server (in Development Mode)

```
    rails s
```

## Running the Tests

```
    # TBD, once we have tests again.
```

## API Endpoints

Here are the routes:

# Get all the groups:
/api/groups

# Get a single group:
/api/groups?ids=1

# Get a single person
/api/people.json?ids=10000473

# Get multiple groups:
/api/groups?ids=1,2

# Get multiple people
/api/people.json?ids=10000473,10004371


---

# Get a person's network (Still has some performance issues)
/api/network?ids=10004371

# Get the intersection of two people:
/api/network?ids=10004371,10013232


# Get a group's network:
/api/groups/network?ids=1


---

# Get group typeahead
/api/typeahead?type=group&q=council

# Get person typeahead (not working)
/api/typeahead?type=group&q=francis

