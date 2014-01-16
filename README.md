foo

TaxonWorks
==========

[![Continuous Integration Status][1]][2]
[![Coverage Status][3]][4]
[![CodePolice][5]][6]
[![Dependency Status][7]][8]

Overview
--------

TaxonWorks is Ruby on Rails application that facilitates biodiversity informatics research.  More information is available at [taxonworks.org][13].  The codebase is in active development.  At present only models are available (i.e. all interactions are through a command-line interface).

Installation
------------

TaxonWorks is a Rails 4 application using Ruby 2.0 and rubygems.  It requires PostgreSQL with the postgis extension.  The core development team is using [rvm] and [brew][9] to configure their environment on OS X.  

Minimally, the following steps should get you going: 

1. Install Postgres and postgis.
  
   ``` 
   brew install postgres
   brew install postgis
   ```

2. To start postgres follow the instructions via 'brew info postgres'. The following sets postgres to start at logon, and then starts postgres for this session:

   ```  
   mkdir -p ~/Library/LaunchAgents    # This may already exist.   
   ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
   launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
   ```
 
3. Clone the source code.

   ```
   git clone git@github.com:SpeciesFileGroup/taxonworks.git
   ```

4. Copy the config/database.yml.example file to config/database.yml.  

5. Given not modifications to database.yml you can proceed by creating a postgres role (user).

   ```
   psql -d postgres
   create role taxonworks_development login createdb superuser; 
   \q
   ```

6. Install the gems dependencies. Ensure you are using the Ruby version you indend to develop under (check with 'ruby -v'). Install the pg gem with some flags first, then the rest of the gems.

  ```
  env ARCHFLAGS="-arch x86_64" gem install pg -- --with-pg-config=/usr/local/bin/pg_config
  bundle update
  ```

7. Setup the databases.
 
  ``` 
  rake db:setup
  rake db:migrate RAILS_ENV=test
  rake db:migrate RAILS_ENV=development
  ```

8. Test your setup.

  ```
  rspec
  ```

If the tests run, then the installation has been a success.  You'll likely want to go back and further secure your postgres installation and roles at this point.

Other resources
---------------

TaxonWorks has a [wiki][11] for conceptual discussion and aggregating long term help, it also includes a basic roadmap. There is a [developers list][14] for technical discussion. Code is documented inline using [Yard tags][12], see [rdoc][10].  Tweets come from [@TaxonWorks][15].  A stub homepage is at [taxonworks.org][13].

License
-------

TaxonWorks is open source under the MIT License. See LICENSE.txt for more information.

[1]: https://secure.travis-ci.org/SpeciesFileGroup/taxonworks.png?branch=postgres
[2]: http://travis-ci.org/SpeciesFileGroup/taxonworks?branch=postgres
[3]: https://coveralls.io/repos/SpeciesFileGroup/taxonworks/badge.png?branch=postgres
[4]: https://coveralls.io/r/SpeciesFileGroup/taxonworks?branch=postgres
[5]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks.png?branch=postgres
[6]: https://codeclimate.com/github/SpeciesFileGroup/taxonworks?branch=postgres
[7]: https://gemnasium.com/SpeciesFileGroup/taxonworks.png?branch=postgres
[8]: https://gemnasium.com/SpeciesFileGroup/taxonworks?branch=postgres
[9]: http://brew.sh/
[10]: http://rubydoc.info/github/SpeciesFileGroup/taxonworks/frames
[11]: http://wiki.taxonworks.org/
[12]: http://rdoc.info/gems/yard/file/docs/Tags.md
[13]: http://taxonworks.org
[14]: https://groups.google.com/forum/?hl=en#!forum/taxonworks-developers
[15]: https://twitter.com/taxonworks
