module UR
  class InternalStreaming
    # Ett RuntimeError som indikerar att ids argumentet är tomt
    class IdsArgumentEmpty < RuntimeError; end
    
    if !defined?(METADATA_CACHE_URL)
      METADATA_CACHE_URL = 'http://metadata.ur.se/'
    end
    
    def initialize(data)
      @data = data
    end
    
    def [](product)
      @data[product.ur_product_id.to_s]
    end
    
    def self.search(search_result)
      ids = search_result.solr.docs.map { |d| d['id'] }
      raise IdsArgumentEmpty if ids.empty?
      url = METADATA_CACHE_URL +
            '/internal_streaming.json?ur_product_ids=' + ids.join(',')
      InternalStreaming.new(JSON.parse(RestClient.get(url).body))
    end
    
    def self.find(id)
      data = {}
      
      result = search([id.to_s])
      
      if result.code == 200
        data = result[id.to_s]
      end
      
      data
    end
  end
end