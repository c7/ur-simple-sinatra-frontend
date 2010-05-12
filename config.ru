require 'rubygems'
require 'sinatra'
require 'app.rb'

set :run, false
run Sinatra::Application
