# Monkey patching for fun and profit
module UR
  class Search
    SEARCH_SERVICE_URL = 'http://localhost:8080/search'
  end
end

# Requirements
require 'sinatra'
require 'enumerator'
require 'lib/ur_helpers'
require 'ur-product'
require 'ur-sab'

# Application

set :haml, { :format => :html5 }

get %r{/(\d{6})} do |ur_product_id|
  product = UR::Product.find(ur_product_id)
  if !product.nil?
    haml :show, :locals => { 
      :page_title => "UR Produktsök — #{product.title}",
      :body_class => 'product',
      :product => product
    }
  else
    redirect '/'
  end
end

get '/subjects' do
  sab_search = UR::SabSearch.new(params[:sab_code])
  
  if sab_search.subjects.count == 1
    redirect facet_link('sab_subjects', sab_search.subjects.first.code)
  end
  
  haml :subjects, :locals => {
    :page_title => 'Navigera i trädstrukturen – UR Produktsök',
    :body_class => 'subjects',
    :selected_sab => sab_search.sab,
    :subjects => sab_search.subjects
  }
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
  tag_cloud = (search_result.ok?) ? build_tag_cloud(search_result) : false
  
  haml :index, :locals => {
    :page_title => 'UR Produktsök',
    :current_page => current_page,
    :search => search_result,
    :tag_cloud => tag_cloud,
    :body_class => 'search',
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

post '/autocomplete.json' do
  content_type :json
  term = URI.escape(params[:value])
  url = UR::Search::SEARCH_SERVICE_URL +
        "/terms?wt=json&terms.fl=search_ao&terms.prefix=#{term}"
  response = JSON.parse(RestClient.get(url).body)
  
  response['terms'][1].each_slice(2).each.map { |t|
    { :value => t[0], :display => t[0] }
  }.to_json
end

get '/stylesheets/style.css' do
  content_type :css
  sass :style
end
