Patch by eyesee: allow mailcatcher-cors to run inside an iframe

File 'application.rb' to patch is located in:

/usr/local/lib64/ruby/gems/2.3.0/gems/mailcatcher-cors-0.7.1/lib/mail_catcher/web

-------------------------------------
NOTES from older vbox virtualmachine:
-------------------------------------

# eyesee: path application.rb in web to allow iframing:

insert

      # eyesee: allow iframes
      # see: http://www.seanbehan.com/how-to-enable-iframe-support-on-heroku-with-ruby-on-rails-and-sinatra
      set :protection, except: [:frame_options]

here:

 15 module MailCatcher
 16   module Web 
 17     class Application < Sinatra::Base
 18       set :development, ENV["MAILCATCHER_ENV"] == "development"
 19       set :root, File.expand_path("#{__FILE__}/../../../..")
 20  
 21       # eyesee: allow iframes
 22       # see: http://www.seanbehan.com/how-to-enable-iframe-support-on-heroku-with-ruby-on-rails-and-sinatra
 23       set :protection, except: [:frame_options]
 24  
 25       if development?
 26         require "sprockets-helpers"

 