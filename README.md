# Mudfly (0.0.2)

A Ruby wrapper for the PageSpeed Insights API.

## Requirements

- Ruby >= 2.0.0

## Installation

Add this line to your application's Gemfile:

    gem 'mudfly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mudfly

## Configuration
    
    require 'mudfly'
    
    # Defaults
    
    Mudfly.api_key    # => nil
    Mudfly.user_agent # => "Mudfly Ruby Gem 0.0.1"
    Mudfly.endpoint   # => "https://www.googleapis.com/pagespeedonline/v1/"
    Mudfly.locale     # => "en_US"
    
    # Block Configuration
    
    Mudfly.configure do |config|
      config.api_key    = 'Your API Key Here.'
      config.user_agent = 'New User Agent'
      config.endpoint   = 'Custom Endpoint'
      config.locale     = 'Your Locale Here'
    end
    
    # Single Configuration
    
    Mudfly.api_key    = 'Your API Key Here.'
    Mudfly.user_agent = 'New User Agent'
    Mudfly.endpoint   = 'Custom Endpoint'
    Mudfly.locale     = 'Your Locale Here'

See [this](https://developers.google.com/speed/docs/insights/languages) for a valid list of locales.

## Usage

    require 'mudfly'
    
    # Configure Mudfly here
    
    Mudfly.analyze('https://github.com') # Desktop report for github.com
    Mudfly.analyze('https://github.com', strategy: :desktop) # Same as above
    Mudfly.analyze('https://github.com', strategy: :mobile) # Mobile report for github.com

## Example

    require 'mudfly'
    
    Mudfly.api_key = 'Your API Key Here' 
    
    report = Mudfly.analyze('http://pabloelic.es', strategy: :desktop)
    
    # Report Info
    
    puts "Kind: #{report.kind}"
    puts "ID: #{report.id}"
    puts "Response Code: #{report.response_code}"
    puts "Title: #{report.title}"
    puts "Score: #{report.score}"
    
    # Page Stats
    
    puts "Resources Number: #{report.stats.resources_number}"
    puts "Hosts Number: #{report.stats.hosts_number}"
    puts "Total Request Bytes: #{report.stats.total_request_bytes}"
    puts "Static Resources Number: #{report.stats.static_resources_number}"
    puts "HTML Response Bytes: #{report.stats.html_response_bytes}"
    puts "CSS Response Bytes: #{report.stats.css_response_bytes}"
    puts "JavaScript Response Bytes: #{report.stats.javascript_response_bytes}"
    puts "Image Response Bytes: #{report.stats.image_response_bytes}"
    puts "JavaScript Resources Number: #{report.stats.javascript_resources_number}"
    puts "CSS Resources Number: #{report.stats.css_resources_number}"
    
    # Rules
    
    report.rules.each do |rule|
      puts "Rule Name: #{rule.name}"
      puts "Rule Score: #{rule.score}"
      puts "Rule Impact: #{rule.impact}"
    end
    
    # Report API Version
    
    puts "Report API Version: #{report.version.major}.#{report.version.minor}"

## Copyright

Copyright &copy; 2013 Pablo Elices. See [license](https://github.com/pabloelices/mudfly/blob/master/LICENSE.txt) for details.