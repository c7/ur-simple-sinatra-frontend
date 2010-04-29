require 'sinatra'
require 'ur-product'

set :haml, { :format => :html5 }

get '/' do
  haml :index, :locals => { 
    :page_title => 'Sök bland Utbildningsradions produkter'
  }
end

get '/products' do
  if !params[:q].nil? && params[:q].length > 0
    @search = UR::Product.search({:q => params[:q]})
    haml :products, :locals => { :page_title => 'Sökning…' }
  else
    redirect '/'
  end
end

get '/stylesheets/style.css' do
  sass :style
end