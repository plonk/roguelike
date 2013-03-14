# -*- coding: utf-8 -*-
class Rectangle
  attr_reader :x, :y, :width, :height

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def vertex(sym)
    case sym
    when :TOP_LEFT
      [@x,          @y]
    when :TOP_RIGHT
      [@x+@width-1, @y]
    when :BOTTOM_LEFT
      [@x,          @y+@height-1]
    when :BOTTOM_RIGHT
      [@x+@width-1, @y+@height-1]
    end
  end

  def set_size(width, height)
    @width = width
    @height = height
  end

  def set_origin(x, y)
    @x = x
    @y = y
  end

  def overlap?(b)
    a = self
    a1_x, a1_y = a.vertex(:TOP_LEFT)
    a2_x, a2_y = a.vertex(:BOTTOM_RIGHT)
    b1_x, b1_y = b.vertex(:TOP_LEFT)
    b2_x, b2_y = b.vertex(:BOTTOM_RIGHT)
    if a1_x <= b2_x and a1_y <= b2_y and a2_x >= b1_x and a2_y >= b1_y
      return true
    else
      return false
    end
  end
end

