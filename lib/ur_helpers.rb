require 'lib/tag_cloud'

# Monkeypatch
class Object
  def blank?
    !(!self.nil? && self.length > 0)
  end
end

module Sinatra
  module URHelpers
    
    include Rack::Utils
    alias_method :h, :escape_html
    
    def mediaplayer_link(id, file)
      link = '/mediaplayer/player.swf?' 
      
      params = {
        'autostart' => 'true',
        'dock' => 'false',
        'lightcolor' => '88C007',
        'frontcolor' => 'ffffff',
        'bufferlength' => 3,
        'width' => 640,
        'height' => 465,
        'skin' => '/mediaplayer/skins/urplay.zip',
        'image' => "http%3A%2F%2Fassets.ur.se%2Fid%2F#{id}%2Fimages%2F1_l.jpg",
        'streamer' => 'rtmp://streaming.ur.se:1935/ondemand',
        'file' => "/#{file}"
      }
      
      "#{link}#{params.each_pair.map { |k,v| "#{k}=#{v}" }.join('&amp;')}"
    end
    
    def build_tag_cloud(search_result)
      cloud = TagCloud.new

      # puts search_result.facets.inspect
      tags = search_result.facets['ao'].slice(0,15)
      
      if tags.size > 0
        tags.each do |tag|
          cloud.add(tag.value, facet_link('ao', tag), tag.hits)
        end
      end

      cloud
    end
    
    def should_show_results?
      !(params[:fq].blank? && params[:q].blank?)
    end
    
    def next_page_link(next_page)
      link = base_link
      
      if link.match(/page\=/)
        link.gsub!(/page\=\d+/, "page=#{next_page}")
      else
        "#{link}&page=#{next_page}"
      end
    end
    
    def facet_filter(name, facet)
      "#{name}:\"#{quoted_value(facet)}\""
    end
    
    def facet_link(name, facet)
      link = base_link
      value = (facet.respond_to?('value')) ? facet.value : facet
      
      if link.match(/fq=/)
        link = link.gsub(/ao:\"[^\"]+?\"/, '') if name == 'ao'
        link = link.gsub('fq=', "fq=#{name}:\"#{value}\" ").
                    gsub(/page\=\d+/, "page=1").sub(' &', '&').gsub('  ', ' ')
      else
        link += '&' if link != '/?'
        link = "#{link}fq=#{name}:\"#{value}\"".gsub(/page\=\d+/, "page=1").gsub(/sab_code\=.+?&/, '')
      end
      
      link
    end
    
    def remove_facet_link(name, facet = false)
      facet = (facet) ? quoted_value(facet) : '[^\"]+?'
      
      link = base_link  
      link = link.gsub(/#{name}:"#{facet}"[ ]{0,}/, '').
                  gsub(/page=\d+/, 'page=1').
                  gsub('?fq=&', '?').sub(' &', '&').sub('  ', ' ')
      link
    end
    
    # Translations
    def translated_facet(name, facet)
      case name
        when 'search_product_type' then translated_product_type(facet.value)
        when 'typicalagerange' then translated_typical_age_range(facet.value)
        else facet.value
      end
    end
    
    def translated_typical_age_range(range)
      translations = {
        'preschool' => 'Förskola',
        'primary0-3' => 'Grundskola 0-3',
        'primary4-6' => 'Grundskola 4-6',
        'primary7-9' => 'Grundskola 7-9',
        'schoolvux'  => 'Vuxenövergripande',
        'university' => 'Högskola',
        'komvuxgrundvux' => 'Komvux/Grundvux',
        'teachereducation' => 'Lärarfortbildning',
        'folkhighschool' => 'Folkhögskola/Studieförbund',
        'secondary' => 'Gymnasieskola',
        'popularadulteducation' => 'Folkbildning'
      }

      translations.has_key?(range) ? translations[range] : range
    end

    def translated_typical_age_ranges(ranges)
      ranges.to_a.map { |range| 
        translated_typical_age_range(range) 
      }.join(', ')
    end
    
    def translated_product_type(type)
      translations = {
        # Program
        'programtv' => 'TV-program',
        'programradio' => 'Radioprogram',
        'programlecture' => 'Föreläsning',

        # Paket
        'packageseries' => 'Serie',
        'packageseries-video' => 'TV-serie',
        'packageseries-audio' => 'Radioserie',
        'packagelecture' => 'Föreläsningsserie',

        'packageusageseries-video' => 'TV-serie',
        'packageusageseries-audio' => 'Radioserie',
        'packageusageseries-composite' => 'Serie',

        'packageproductionpackage-video' => 'TV-serie',
        'packageproductionpackage-audio' => 'Radioserie',
        'packageproductionpackage-composite' => 'Serie',

        'packagecd-audio' => 'CD',
        'packagedvd-video' => 'DVD',

        'packageeducational' => 'Utbildningspaket',
        'packagelearningresource' => 'Lärresurs',

        # Klipp
        'trailertrailer' => 'Klipp',
        'trailerteaser' => 'Smakprov',
        'trailerdigitalstory' => 'Digital berättelse',

        # Text
        'textlanguagescript' => 'Språkmanus',
        'textarticle' => 'Artikel',
        'textpressinfo' => 'Pressinfo',
        'textstudyguide' => 'Studiehandledning',
        'textteacherguide' => 'Lärarhandledning',
        'textscript' => 'Programmanus',
        'textworksheet' => 'Arbetsblad',
        'texttasks' => 'Arbetsuppgifter',
        'texttext' => 'Text',
        'textbooklet' => 'Häfte',

        # Övrigt
        'book' => 'Bok',
        'website' => 'Webbplats'
      }

      translations.has_key?(type) ? translations[type] : type
    end
    
    def translated_languages(languages)
      translations = {
        'alb' => 'Albanska',
        'ara' => 'Arabiska',
        'bos' => 'Bosniska',
        'bul' => 'Bulgariska',
        'chi' => 'Mandarin',
        'cze' => 'Tjeckiska',
        'dan' => 'Danska',
        'dut' => 'Nederländska',
        'eng' => 'Engelska',
        'est' => 'Estniska',
        'fin' => 'Finska',
        'fiu' => 'Meänkieli',
        'fre' => 'Franska',
        'ger' => 'Tyska',
        'gre' => 'Grekiska',
        'heb' => 'Hebreiska',
        'hun' => 'Ungerska',
        'ice' => 'Isländska',
        'ita' => 'Italienska',
        'jpn' => 'Japanska',
        'kaz' => 'Kazakiska',
        'kur' => 'Kurdiska',
        'lav' => 'Lettiska',
        'lit' => 'Litauiska',
        'mis' => 'Övriga språk',
        'mlt' => 'Maltesiska',
        'nor' => 'Norska',
        'per' => 'Persiska',
        'pol' => 'Polska',
        'por' => 'Portugisiska',
        'rom' => 'Romani',
        'rom-arli' => 'Romani/arli',
        'rom-kaal' => 'Romani/kaale',
        'rom-keld' => 'Romani/kelderash',
        'rom-lova' => 'Romani/lovara',
        'rum' => 'Rumänska',
        'rus' => 'Ryska',
        'scr' => 'Kroatiska',
        'sgn-GBR' => 'Engelskt teckenspråk',
        'sgn-SWE' => 'Svenskt teckenspråk',
        'slo' => 'Slovakiska',
        'slv' => 'Slovenska',
        'sma' => 'Sydsamiska',
        'sme' => 'Nordsamiska',
        'smj' => 'Lulesamiska',
        'som' => 'Somaliska',
        'spa' => 'Spanska',
        'srp' => 'Serbiska',
        'swe' => 'Svenska',
        'tha' => 'Thailändska',
        'tur' => 'Turkiska',
        'yid' => 'Jiddisch'
      }

      languages.map { |l| translations.has_key?(l) ? translations[l] : l }.join(', ')
    end
    
  private
    def base_link
      "/?#{params.each_pair.map { |k,v| "#{k}=#{v}" }.join('&')}"
    end
    
    def quoted_value(facet)
      Regexp::quote(facet.value)
    end
  end
  helpers URHelpers
end