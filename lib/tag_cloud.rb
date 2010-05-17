# Initial version by Masaki Yatsu <yatsu@yatsu.info>
# Modified by Peter Hellberg <peter@c7.se>

class TagCloud  
  def initialize
    @counts = Hash.new
    @urls = Hash.new
    tags = []
  end

  def add(tag, url, count)
    @counts[tag] = count
    @urls[tag] = url
  end

  def css
    text = "" 
    for level in 0..18
      font = 12 + level
      text << "span.tagcloud#{level} {font-size: #{font}px;}\n"
    end
    text
  end

  def html(limit = nil)
    tags = @counts.sort_by {|a, b| b }.reverse.map {|a, b| a }
    tags = tags[0..limit-1] if limit
    return "" if tags.empty?
    
    min = Math.sqrt(@counts[tags.last])
    max = Math.sqrt(@counts[tags.first])
    factor = 0

    # special case all tags having the same count
    if max - min == 0
      min = min - 4
      factor = 12
    else
      factor = 12 / (max - min)
    end

    html = ""
    tag_count = 0
    
    tags.sort.each do |tag|
      tag_count += 1
      count = @counts[tag]
      url   = @urls[tag]
      level = ((Math.sqrt(count) - min) * factor).to_i
      html << %{<span class="tagcloud#{level}"><a href='#{URI.escape(url)}'>#{tag}</a>}
      html << ',' if tag_count < tags.size  
      html << "</span>\n" 
    end
    html
  end

  def html_and_css(limit = nil)
    "<div class=\"tagcloud\">\n<style>\n#{self.css}</style>\n#{self.html(limit)}\n</div>"
  end
  
  def empty?
    @counts.empty?
  end
  
  def num_tags
    @urls.size
  end
end