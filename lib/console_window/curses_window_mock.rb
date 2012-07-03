# -*- coding: utf-8 -*-
require 'give4each'

module ConsoleWindow
  class CursesWindowMock
    
    MAXX = 80
    MAXY = 20
    
    def initialize attributes = {}
      {
        :maxx => MAXX,
        :maxy => MAXY,
        :input_text => '',
        :screen => '',
        :cury => 0,
        :curx => 0
      }.merge(attributes).each do |attr, val|
        send :"#{attr}=", val
      end
    end
    
    attr_reader :input_text

    def input_text= text
      @input_text = text
      @input_text_buffer = text.each_byte.to_a
    end

    # 互換性のため
    alias text input_text
    alias text= input_text=

    attr_accessor :maxx
    attr_accessor :maxy
    attr_accessor :curx
    attr_accessor :cury
    attr_accessor :screen

    def screen= text
      @screen = text.split("\n").map &:each_char.and_to_a
    end

    def addstr str
      str.each_char do |b|
        if @curx >= maxx
          @curx = 0
          @cury += 1
        end

        (@screen[cury] ||= [])[@curx] = b
        @curx += 1
      end
      nil
    end
    
    def getch
      @input_text_buffer.shift
    end
  end
end
