# Monkeypatch
class Object
  def blank?
    !(!self.nil? && self.length > 0)
  end
end

module Sinatra
  module URHelpers
    
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
      
      if link.match(/fq=/)
        link = link.gsub('fq=', "fq=#{name}:\"#{facet.value}\" ").
                    gsub(/page\=\d+/, "page=1").sub(' &', '&')
      else
        link += '&' if link != '/?'
        link = "#{link}fq=#{name}:\"#{facet.value}\"".gsub(/page\=\d+/, "page=1")
      end
      
      link
    end
    
    def remove_facet_link(name, facet)
      link = base_link  
      link = link.gsub(/#{name}:"#{quoted_value(facet)}"[ ]{0,}/, '').
                  gsub('?fq=&', '?').sub(' &', '&')
      link
    end
    
    def translated_facet(name, facet)
      case name
        when 'search_product_type' then translated_product_type(facet.value)
        when 'typicalagerange' then translated_typical_age_range(facet.value)
        else facet.value
      end
    end
    
    # Translations
    
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