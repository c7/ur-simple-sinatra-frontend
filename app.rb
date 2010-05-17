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
require 'lib/ur_internal_streaming.rb'
require 'ur-product'
require 'ur-sab'

# Configuration

configure :development do
  puts "DEVELOPMENT: Reloading application"
end

configure :production do
  require 'memcached'
  require 'rack/cache'
    
  use Rack::Cache,
    :verbose     => true,
    :metastore   => 'memcached://localhost:11211/ur-simple-search-meta',
    :entitystore => 'memcached://localhost:11211/ur-simple-search-body'
end

# Application

set :haml, { :format => :html5 }

get %r{/(\d{6})} do |ur_product_id|
  response["Cache-Control"] = "max-age=60, public" 
  
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
  response["Cache-Control"] = "max-age=300, public"
  
  sab_search = UR::SabSearch.new(params[:sab_code])
  
  if sab_search.subjects.count == 1
    redirect facet_link('sab_subjects', sab_search.subjects.first.code)
  end
  
  haml :subjects, :locals => {
    :page_title => 'Bläddra ämnesvis – UR Produktsök',
    :body_class => 'subjects',
    :selected_sab => sab_search.sab,
    :subjects => sab_search.subjects
  }
end

get '/' do
  # Caching
  response["Cache-Control"] = "max-age=60, public"
  
  # Defaults
  current_page = 1
  search_params = { :per_page => 10 }
  search_result = nil
  
  # Filter query
  if !params[:fq].nil? && params[:fq].length > 0
    search_params[:fq] = params[:fq]
  end
  
  # Query
  if !params[:q].nil? && params[:q].length > 0
    search_params[:q] = params[:q]
  end
  
  # Page
  if !params[:page].blank? && params[:page].match(/^\d+$/)
    search_params[:page] = params[:page].to_i
    current_page = search_params[:page]
  end
  
  # Stream filtering
  if !params[:stream_filter].nil?
    case params[:stream_filter]
      when 'internet' then search_params[:publicstreaming] = 'NOW'
      when 'avc' then search_params[:avcstreaming] = 'NOW'
    end
  end
  
  # Sorting
  search_params[:sort] = (params[:sort].nil?) ? 'score desc' : params[:sort]
  
  # SAB subjects
  if !params[:fq].nil? && match = params[:fq].match(/sab_subjects:\"(.+?)\"/)
    selected_sab = UR::Sab.new(match[1])
  else
    selected_sab = false
  end
  
  begin
    search_result   = UR::Product.search(search_params)
    
    begin 
      streaming_data = UR::InternalStreaming.search(search_result)
    rescue UR::InternalStreaming::IdsArgumentEmpty
      streaming_data = []
    end
    
    tag_cloud = (search_result.ok?) ? build_tag_cloud(search_result) : false
    
    haml :index, :locals => {
      :page_title => 'UR Produktsök',
      :current_page => current_page,
      :search => search_result,
      :tag_cloud => tag_cloud,
      :selected_sab => selected_sab,
      :streaming_data => streaming_data,
      :body_class => 'search',
      :facet_order => [
        ['search_product_type', 'Typ'],
        ['typicalagerange', 'Målgrupp'],
        ['language', 'Talat språk'],
        ['subtitle_languages', 'Textning'],
        ['productionyear', 'Produktionsår'],
        ['sli_entry', 'SLI-kod']
      ]
    }
  rescue Errno::ECONNREFUSED => e
    haml '%div.container-12
          %h1="Något gick snett!"
          %p="Kunde inte ansluta till sökmotorn"', :locals => {
      :body_class => 'error',
      :page_title => 'Kunde inte ansluta till sökmotorn - UR Produktsök'
    }
  end
end

post '/autocomplete.json' do
  response["Cache-Control"] = "max-age=120, public"
  
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
  response["Cache-Control"] = "max-age=120, public"
  
  content_type :css
  sass :style
end
