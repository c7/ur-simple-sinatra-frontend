require 'rubygems'
require 'memcached'
require 'rack/cache'
require 'sinatra'
require 'app.rb'

set :run, false
set :environment, :production

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'memcached://localhost:11211/ur-simple-sinatra-frontend-meta',
  :entitystore => 'memcached://localhost:11211/ur-simple-sinatra-frontend-body'
  
run Sinatra::Application
