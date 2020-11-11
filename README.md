# office-time

Just for kicks, I've been tracking my comings and goings.

## Prepare
Install the libraries needed first:

    gem install business_time
    bundle install

Download the IFFT Google Sheet as CSV and save locally. Run `ruby parse.rb <filename>` to parse its data.

## Serve locally
    bundle exec jekyll serve

## Build website files
    bundle exec jekyll build