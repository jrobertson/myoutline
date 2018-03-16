#!/usr/bin/env ruby

# file: myoutline.rb

require 'pxindex'



class MyOutline

  def initialize(raw_s, debug: false)

    # find the entries which aren't on the main index
    s = raw_s.sub(/<[^>]+>\n/,'')
    doc = LineTree.new(s, debug: debug).to_doc(encapsulate: true)
    a = doc.root.xpath('entry/text()')
    a2 = doc.root.xpath('entry//entry/text()')
    a3 = a2 - a
    
    # add the new entries to the main index
    s << a3.join("\n")

    s.prepend '<?ph schema="entries/entry[title]"?>

    '
    
    @pxi = PxIndex.new(s, debug: debug)
    @px = @pxi.to_px

  end
  
  def save(filename=myoutline.txt)
    File.write filename, @pxi.to_s
  end
  
  def to_s()
    @pxi.to_s
  end

end

