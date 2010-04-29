require 'rubygems'
require 'sinatra'
require 'app.rb'

set :run, false
set :environment, :production
run Sinatra::Application