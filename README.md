# Six Degrees of Francis Bacon

The repository contains the codebase for the *Six Degrees of Francis Bacon* web application. For the network inference and estimation code, see [this separate repository](https://github.com/sdfb/sdfb_network), and for the original 2015 beta site, see the 2015-beta branch of this repo.

Six Degrees of Francis Bacon is a digital reconstruction of the early modern social network that scholars and students from all over the world can collaboratively expand, revise, curate, and critique. Unlike published prose, Six Degrees is extensible, collaborative, and interoperable: extensible in that people and associations can always be added, modified, developed, or, removed; collaborative in that it synthesizes the work of many scholars; interoperable in that new work on the network is put into immediate relation to previously studied relationships.

The code in this repository runs the web application which supports this collaborative digital reconstruction. It is made up of a Ruby on Rails backend (a set of API endpoints that communicate with a Postgres database), and an AngularJS frontend. Included in the Angular code is a set of D3js network visualizations. The code is split into modularized chunks for easy reuse. For example, the code for the network graphs can be found in `angular/app/scripts/directives/forcelayout.js`. Instructions for how to get this code up and running on your own server are below.

# Installation and Server Setup

All of these instructions assume a basic Linux (Ubuntu) server with Postgres, Ruby, Rails, and Node already installed.

## Set up Postgres database:

1. Set a new password for the postgres user with `sudo passwd postgres`
2. Make sure this password matches the password in `database.yml`
3. Access machine as user postgres with `su - postgres`
4. Get plaintext backup file from existing database. On whatever other server or machine your database lives on, this often looks like:
`psql mydatabase > mybackup.dump`
5. Create a new database on the server with `createdb sixdfbor_sdfb`
6. Populate that database with your backup file: `psql sixdfbor_sdfb < somefile.dump`
7. Make sure you can log in to the database from the rails app. You'll want to edit a config file by typing `sudo vim /etc/postgresql/9.5/main/pg_hba.conf`. Then change `peer` on the first line to `md5`.
8. Restart postgres with `sudo service postgresql restart` to implement these changes.

## Set up the App:

Before you do anything else, clone this Github repo into `/var/www`. Just navigate to that directory and type `git clone https://github.com/sdfb/sdfb.git`

### In angular app:

1. Go to the app by typing `cd sdfb/angular`
2. Type the following commands in order. You may have to use `sudo` and type in a password for any of these.

`npm install`

`npm install -g bower`

`bower install` (with `--allow-root` option if using sudo)

`npm install -g grunt-cli`

`sudo gem install compass`

`sudo grunt build`

3. Now angular is ready to go. For future changes to the site, you'll want to run `sudo grunt build` again to rebuild the site.

### In rails app:

I will be following these: https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/trusty/deploy_app.html

1. Make your Gemfile.lock writeable: `sudo chmod 777 Gemfile.lock`
2. `bundle install` (If you get an error with this, you may need to make your Gemfile match your local version of ruby.)

**Run these next steps only after the database has been set up (see above)**

1. Run `bundle exec rake secret` and copy the resulting code to the clipboard.
2. Create the file `config/secrets.yml` with the following contents:
```
production:
  secret_key_base: [the value that you copied from 'rake secret']
```
3. Compile your assets and migrate database: `sudo bundle exec rake assets:precompile db:migrate RAILS_ENV=production`
4. Follow [these instructions](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/xenial/install_passenger.html) to install Passenger.
5. Add or uncomment `include /etc/nginx/passenger.conf;` to `/etc/nginx/nginx.conf`
6. Restart Nginx: `sudo service nginx restart`
6. Now rails is ready to go. For future changes to the site, you may have to run `sudo bundle exec rake assets:precompile db:migrate RAILS_ENV=production` again to recompile assets. You'll also want to restart Nginx: `sudo service nginx restart`

## Set up Nginx

1. Update `/etc/nginx/sites-enabled/default` to match the one [here](https://www.phusionpassenger.com/library/deploy/nginx/deploy/ruby/).
```
        root /var/www/sdfb/angular/dist;
        passenger_enabled on;

        location ~ ^/tools(/.*|$) {
            alias /var/www/sdfb/rails/public$1;  # <-- be sure to point to 'public'!
            passenger_base_uri /tools;
            passenger_app_root /var/www/sdfb/rails;
            passenger_document_root /var/www/sdfb/rails/public;
            passenger_enabled on;

        }
```
2. Restart Nginx: `sudo service nginx restart`

That's it! The Angular app and Rails API should both be live on the server. If your API/frontend hookup isn't working, make sure the apiUrl is correct in `angular/app/scripts/services/apiservice.js`.
