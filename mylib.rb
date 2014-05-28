# -*- coding: utf-8 -*-
# グローバルに使える便利関数

# アスカは 56 × 34
# マス数
WIDTH = 56
HEIGHT = 34
# ピクセル
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

FPS = 60

# POSSIBLE DIRECTIONS
DOWN = 0
LEFT = 1
RIGHT = 2
UP = 3
UPPER_RIGHT = 4
BOTTOM_RIGHT = 5
BOTTOM_LEFT = 6
UPPER_LEFT = 7

ALL_DIRECTIONS = [DOWN, LEFT, RIGHT, UP, 
  UPPER_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT, UPPER_LEFT]

$frame_count = 0
def main_loop(frame = -1)
  i = 0
  $time_elapsed_in_frame = 0 # for the first frame
  while true
    break if i == frame
    
    ta = Time.now
    yield
    tb = Time.now

    $time_elapsed_in_frame = tb-ta
    x = (1.0/FPS) - (tb-ta)
    if x > 0
      SDL.delay(x*1000)
    else
    end
    $screen.flip

    i += 1
    $frame_count += 1
  end
end

def load_png(filename)
  png = Surface.load(filename)
  color_keyed = Surface.new(HWSURFACE, png.w, png.h, $screen.format)
  color_keyed.fill_rect(0, 0, png.w, png.h, [255,0,255]) # hot pink
  color_keyed.set_color_key(SRCCOLORKEY, [255,0,255])
  color_keyed.put(png, 0, 0)
  return color_keyed
end

def assert(exp, msg = nil)
  if exp == false
    if msg
      raise msg
    else
      raise
    end
  end
end

require_relative 'rgb_db'

def get_color(name)
  $rgb_db ||= RGB_DB.new
  code = $rgb_db.from_name_to_code(name)
  if code == nil
    return nil
  elsif code =~ /^#(..)(..)(..)$/
    r, g, b = $1.hex, $2.hex, $3.hex
    return [r, g, b]
  else
    raise
  end
end

def direction_to_offsets(dir)
  x = 0; y = 0
  x -= [LEFT, BOTTOM_LEFT, UPPER_LEFT].count(dir)
  x += [RIGHT, BOTTOM_RIGHT, UPPER_RIGHT].count(dir)
  y -= [UP, UPPER_RIGHT, UPPER_LEFT].count(dir)
  y += [DOWN, BOTTOM_RIGHT, BOTTOM_LEFT].count(dir)
  return x, y
end

def offsets_to_direction(offset)
  case offset
  when [0,1]
    DOWN 
  when [-1,0]
    LEFT
  when [+1,0]
    RIGHT
  when [0,-1]
    UP
  when [+1,-1]
    UPPER_RIGHT 
  when [+1,+1]
    BOTTOM_RIGHT
  when [-1,+1]
    BOTTOM_LEFT
  when [-1,-1]
    UPPER_LEFT
  else
    raise "argument range error #{offset.insepct}"
  end
end
