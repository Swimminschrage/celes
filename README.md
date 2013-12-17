Celes
=====

A simple Ruby gem for parsing snippets of text and images based on the HTML content at a provided URL.

## Installation

Add this line to your application's Gemfile:

    gem 'celes-web'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install 'celes-web'

## Usage

Require 'celes' and then construct a Celes object providing the URL to parse

    require 'celes'
    c = Celes.new(url: 'http://www.yahoo.com')

Calling '#snippets' without any options will get the text snippets that are at least 40 characters long

    c.snippets #=> ['Array', 'of', 'Strings']

Calling '#images' without any options will get the source field for any images on the page

    c.images #=> ['Array', 'of', 'Strings']

### Options

Use 'min_snippet_length' to define the minimum length of text in the document node to be considered a "snippet".  The default is 40 characters.

    c = Celes.new(url: 'http://www.yahoo.com', min_snippet_length: 100)

Use 'snip_length' to truncate longer snippets down to a shorter length.  By default, Celes will truncate snippets to 140 characters.

    c = Celes.new(url: 'http://www.yahoo.com', snip_length: 45)

