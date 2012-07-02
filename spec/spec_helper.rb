
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

class CursesWindowMock

  MAXX = 80
  MAXY = 20


  def initialize attributes = {}
    {
      :maxx => MAXX,
      :maxy => MAXY
    }.merge(attributes).each do |attr, val|
      send :"#{attr}=", val
    end
  end

  attr_accessor :maxx
  attr_accessor :maxy
end
