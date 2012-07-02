
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

class CursesWindowMock

  MAXX = 80
  MAXY = 20


  def initialize attributes = {}
    {
      :maxx => MAXX,
      :maxy => MAXY,
      :text => '',
      :seek => 0,
    }.merge(attributes).each do |attr, val|
      send :"#{attr}=", val
    end
  end

  attr_accessor :maxx
  attr_accessor :maxy
  attr_accessor :text
  attr_accessor :seek

  def getch
    text.bytes.to_a[seek].tap do |c|
      if c
        self.seek += 1
      end
    end
  end
end
