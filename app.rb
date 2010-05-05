# Requirements

require 'sinatra'
require 'lib/ur_helpers'
require 'ur-product'

# Application

set :haml, { :format => :html5 }

get %r{/(\d{6})} do |ur_product_id|
  product = UR::Product.find(ur_product_id)
  if !product.nil?
    haml :show, :locals => { 
      :page_title => "UR Produktsök — #{product.title}",
      :product => product
    }
  else
    redirect '/'
  end
end

get '/' do
  current_page = 1
  search_params = { :per_page => 10 }
  search_result = nil
  
  if !params[:fq].nil? && params[:fq].length > 0
    search_params[:fq] = params[:fq]
  end
    
  if !params[:q].nil? && params[:q].length > 0
    search_params[:q] = params[:q]
    
    if !params[:page].blank? && params[:page].match(/^\d+$/)
      search_params[:page] = params[:page].to_i
      current_page = search_params[:page]
    end
  end
  
  search_result = UR::Product.search(search_params)
  
  haml :index, :locals => { 
    :page_title => 'UR Produktsök',
    :current_page => current_page,
    :search => search_result,
    :facet_order => [
      ['search_product_type', 'Typ'],
      ['typicalagerange', 'Målgrupp'],
      ['subtitle_languages', 'Textning'],
      ['productionyear', 'Produktionsår'],
      ['language', 'Språk'],
      ['sli_entry', 'SLI-kod']
    ]
  }
  
end

get '/stylesheets/style.css' do
  content_type :css
  sass :style
end