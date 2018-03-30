#!/usr/bin/env ruby

# file: myoutline.rb

require 'pxindex'
require 'nokogiri'


class MyOutline
  
  attr_reader :pxi

  def initialize(source, debug: false, allsorted: true, 
                 autoupdate: true, topic_url: '$topic')
    
    @debug, @source, @topic_url = debug, source, topic_url

    raw_s, _ = RXFHelper.read(source)
    
    # find the entries which aren't on the main index
    s = raw_s.sub(/<[^>]+>\n/,'')
    doc = LineTree.new(s, debug: true).to_doc(encapsulate: true)
    a = doc.root.xpath('entry/text()')
    puts 'doc: ' + doc.xml if debug
    a2 = doc.root.xpath('entry//entry/text()')
    puts 'a2: ' + a2.inspect if debug
    a3 = a2 - a
    puts 'a3:' + a3.inspect if debug
    
    # add the new entries to the main index
    s << a3.join("\n")

    s.prepend '<?ph schema="entries/section[heading]/entry[title, url]"?>

    '
    
    @pxi = PxIndex.new(s, debug: debug, indexsorted: true, 
                       allsorted: allsorted)
    save() if autoupdate and self.to_s != raw_s

  end
  
  def save(filename=nil)
    
    if filename.nil? then
      filename = RXFHelper.writeable?(@source) ? @source : 'myoutline.txt'
    end
  
    RXFHelper.write filename, self.to_s(declaration: true)
    
  end
  
  def to_html()

    px = self.to_px
    
    px.each_recursive do |x, parent|
      
      if x.is_a? Entry then
        
        trail = parent.attributes[:trail]
        s = x.title.gsub(/ +/,'-')
        x.attributes[:trail] = trail.nil? ? s : trail + '/' + s
        
      end
      
    end

    doc   = Nokogiri::XML(px.to_xml)
    xsl  = Nokogiri::XSLT(xslt())

    doc = Rexle.new(xsl.transform(doc).to_s)
        
    doc.root.css('.atopic').each do |e|      
      puts 'e: ' + e.parent.parent.xml.inspect if @debug
      e.attributes[:href] = @topic_url.sub(/\$topic/, e.text)\
          .sub(/\$id/, e.attributes[:id]).sub(/\$trail/, e.attributes[:trail])\
          .to_s.gsub(/ +/,'-')
    end
    
    doc.xml(pretty: true)
    
  end
  
  def to_px()
    @pxi.to_px
  end
  
  def to_s(declaration: false)
    
    if declaration == true then
      @pxi.to_s.sub(/(?<=^\<\?)([^\?]+)/,'myoutline')
    else
      @pxi.to_s.lines[1..-1].join.lstrip
    end
    
  end
  
  def to_tree(alphabet: true)
    
    a  = @pxi.to_s.lines
    a.shift # remove the ph declaration
    a.reject! {|x| x =~ /^(?:#[^\n]+|\n+)$/} unless alphabet
    a.map! {|x| r = x[/^.*(?= # )/]; r ? r + "\n" : x } # strip out the URLS
    
    a.join
    
  end
  
  private
  
  def xslt()
<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />

<xsl:template match='entries'>
  <ul>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>
  </ul>
</xsl:template>

<xsl:template match='entries/summary'>
</xsl:template>

<xsl:template match='records/section'>
  <li><h1><xsl:value-of select="summary/heading"/></h1><xsl:text>
      </xsl:text>

    <xsl:apply-templates select='records'/>

<xsl:text>
    </xsl:text>
  </li>
</xsl:template>


<xsl:template match='records/entry'>
    <ul id="{summary/title}">
  <li><xsl:text>
          </xsl:text>
          <a href="{summary/url}" class='atopic' id='{@id}' trail='{@trail}'>
          <xsl:value-of select="summary/title"/></a><xsl:text>
          </xsl:text>

    <xsl:apply-templates select='records'/>

<xsl:text>
        </xsl:text>
  </li>
    </ul>
</xsl:template>


</xsl:stylesheet>    
EOF
  end

end
