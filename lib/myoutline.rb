#!/usr/bin/env ruby

# file: myoutline.rb

require 'pxindex'
require 'nokogiri'
require 'filetree_xml'
require 'polyrex-links'
require 'md_edit'


class MyOutline
  
  attr_reader :outline
  attr_accessor :md
  
  class Outline
    using ColouredText
    
    attr_reader :ftx, :links, :pxi
    
    def initialize(source, debug: false, allsorted: true, autoupdate: true)
      
      @debug, @source = debug, source
      @allsorted, @autoupdate = allsorted, autoupdate
      
      build_index(source)

    end
    
    def autosave(s=nil)
      
      puts ('inside autosave ; @autoupdate: ' + @autoupdate.inspect).debug if @debug
      
      if @autoupdate then
        puts 'before save'.info if @debug
        save() if s.nil? or self.to_s != s      
      end
      
    end

    def build_html(&blk)
      @pxi.build_html(&blk)
    end
    
    def locate(s)
      @links.locate s
    end
      
    def ls(path='.')
      @ftx.ls(path).map(&:to_s)
    end    
    
    def save(filename=nil)
      
      if filename.nil? then
        filename = RXFHelper.writeable?(@source) ? @source : 'myoutline.txt'
      end
    
      RXFHelper.write filename, self.to_s(declaration: true)
      
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
    
    def to_tree
      format_tree(alphabet: true, nourl: true)
    end
    
    def to_treelinks
      format_tree()
    end    
    
    private
    
    def build_index(s)
      
      @pxi = PxIndex.new(debug: @debug, indexsorted: @indexsorted, 
                         allsorted: @allsorted)
      @pxi.import s
      autosave(s)
      read(self.to_treelinks)
      
    end

    def format_tree(alphabet: false, nourl: false)
      
      a  = @pxi.to_s.lines
      a.shift # remove the ph declaration
      a.reject! {|x| x =~ /^(?:#[^\n]+|\n+)$/} unless alphabet
      
      if nourl then
        # strip out the URLS?
        a.map! {|x| r = x[/^.*(?= # )/]; r ? r + "\n" : x }
      end
      
      a.join
      
    end      

    def read(s)
      
      @links = PolyrexLinks.new.import(s, debug: @debug)
      
      s3 = s.lines.map {|x| x.split(/  | # /,2)[0]}.join("\n")
      @ftx = FileTreeXML.new(s3, debug: @debug)    
      
    end    

  end

  def initialize(source, debug: false, allsorted: true, autoupdate: true, 
                 topic_url: '$topic', md_path: '.', default_md: 'main.md')
    
    @debug, @topic_url = debug, topic_url
    @md_path = md_path
    @default_md = default_md
    @allsorted, @autoupdate = allsorted, autoupdate

    @outline = Outline.new(source, debug: debug, 
                           allsorted: allsorted, autoupdate: autoupdate)

  end
  
  def fetch(uri)

    s, remaining = @outline.locate(uri)
    puts 'fetch() s: ' + s.inspect if @debug
    redirect = s =~ /^\[r\] +/i
    return s if redirect 
    
    s ||= @default_md; remaining ||= ''
    
    f = File.join(@md_path, s)
    puts 'f: ' + f.inspect if @debug
    @md = MdEdit.new f, debug: @debug
    r = edit(remaining.sub(/^\//,'').gsub(/\//,' > '))    
    puts 'fetch() r: ' + r.inspect if @debug
    @md.update r
    
    r
  end
  
  def rebuild(s)
    @outline = Outline.new s
  end
  
  def update(section)
    @md.update section
  end  
  
  def update_tree(s)
    
    mo2 = Outline.new(s, debug: @debug, 
                           allsorted: @allsorted, autoupdate: @autoupdate)
    
    h = @outline.links.to_h
    links = mo2.links
    
    mo2.links.to_h.each do |title, file|
      
      if @debug then
        puts 'title: ' + title.inspect
        puts 'h[title]: ' + h[title].inspect
      end
      
     links.link(title).url = h[title] if h[title]
    end
    
    puts 'before Outline.new: ' + links.to_s(header: false).inspect if @debug
    
    @outline  = Outline.new(links.to_s(header: false), debug: @debug, 
                           allsorted: @allsorted, autoupdate: @autoupdate)
    @outline.autosave
  end
  
  def to_html()
    
    @outline.build_html do |e|
      
      e.attributes[:href] = @topic_url.sub(/\$topic/, e.text)\
          .sub(/\$id/, e.attributes[:id]).sub(/\$trail/, e.attributes[:trail])\
          .to_s.gsub(/ +/,'-')      
      
    end    
    
  end
  
  def to_s()
    @outline
  end
  
  
  private
  
  def edit(s)

    r = @md.find s
    return r if r

    a = s.split(/ *> */)

    if a.length > 1 then

      heading = a.pop.capitalize
      r2 = edit(a.join(' > '))
      n = r2.scan(/^#+/).last.length

      r2 + ("\n%s %s\n" % [('#' * (n+1)), heading])

    end

  end


end
