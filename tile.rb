# -*- coding: utf-8 -*-
require 'sdl'
include SDL


SPC = "　"
class String
  def get(x, y)
    return SPC if x <= 0 or x >= WIDTH-1 or y <= 0 or y >= HEIGHT-1
    return self[y * WIDTH + x]
  end
end

White = [255,255,255]
Black = [0, 0, 0]
Gray = [168, 168, 168]
Gray2 = [128, 128, 128]
Gray4 = [64, 64, 64]
Green = [0,128,128]
Yellow = [255, 250, 205]

#WIDTH = 40
#HEIGHT = 30
WIDTH = 20
HEIGHT = 15
SCREEN_WIDTH = WIDTH*32
SCREEN_HEIGHT = HEIGHT*32

def get_color(name)
  # rgb.txt 
#  return [, , ]
end

fname = 'C:/Users/plonk/Downloads/Notbrave2/Graphics/Tilesets/Dungeon_A1.png'
img = Surface.load(fname)
@img2 = Surface.load("C:/Users/plonk/Downloads/Notbrave2/Graphics/Tilesets/Dungeon_A2.png")

SDL.init( INIT_VIDEO|INIT_JOYSTICK )

@screen = Screen.open(SCREEN_WIDTH, SCREEN_HEIGHT, 16, HWSURFACE)

WM.set_caption("tile", "")

if Joystick.num == 0 then
  print "No joystick available\n"
  exit
end

FPS = 60

=begin
  tile = Surface.new(HWSURFACE, 32, 32, tileset.format)
  pos.each_with_index do |pair, i|
    x, y = pair
    Surface.blit(tileset, x*16, y*16, 16, 16, tile, i * 16 % 32, (i * 16 / 32)*16)
  end
=end

# 40%の確率で壁、60%の確率で通路を作るコード
def phase1(buf)
  (0...WIDTH).each do |x|
    (0...HEIGHT).each do |y|
      unless x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        buf[y*WIDTH+x] = (0..0.4).include?(rand) ? "■" : SPC
      end
    end
  end
  return buf
end

def phase2(buf)
  old = buf
  buf = buf.dup 
  (0...WIDTH).each do |x|
    (0...HEIGHT).each do |y|
      if x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        next
      end

      wc = 0 # wall count
      wc += 1 if old.get(x - 1, y - 1) == "■"
      wc += 1 if old.get(x    , y - 1) == "■"
      wc += 1 if old.get(x + 1, y - 1) == "■"
      wc += 1 if old.get(x - 1, y    ) == "■"
      # oldget(x    , y    )
      wc += 1 if old.get(x + 1, y    ) == "■"
      wc += 1 if old.get(x - 1, y + 1) == "■"
      wc += 1 if old.get(x    , y + 1) == "■"
      wc += 1 if old.get(x + 1, y + 1) == "■"

      wc2 = wc # wall count
      wc2 += 1 if old.get(x - 2, y - 1) == "■"
      wc2 += 1 if old.get(x - 2, y    ) == "■"
      wc2 += 1 if old.get(x - 2, y + 1) == "■"
      wc2 += 1 if old.get(x + 2, y - 1) == "■"
      wc2 += 1 if old.get(x + 2, y    ) == "■"
      wc2 += 1 if old.get(x + 2, y + 1) == "■"
      wc2 += 1 if old.get(x - 1, y - 2) == "■"
      wc2 += 1 if old.get(x + 0, y - 2) == "■"
      wc2 += 1 if old.get(x + 1, y - 2) == "■"
      wc2 += 1 if old.get(x - 1, y + 2) == "■"
      wc2 += 1 if old.get(x + 0, y + 2) == "■"
      wc2 += 1 if old.get(x + 1, y + 2) == "■"

      if wc >= 5 or wc2 <= 2
        buf[y*WIDTH+x] = "■"
      else
        buf[y*WIDTH+x] = SPC
      end
    end
  end
  old.replace(buf)
end

def print_buffer(buf)
  (0...HEIGHT).each do |y|
    (0...WIDTH).each do |x|
      if x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        # do nothing
        Surface.blit(@img2, 0, 0, 32, 32, @screen, x * 32, y * 32)
        next
      end
      tile = nil
      if buf.get(x, y) == "■"
        # ab
        # cd

        # a
        diagonal = buf.get(x - 1, y - 1)
        vertical = buf.get(x, y - 1)
        side = buf.get(x - 1, y)
        if diagonal == "　" and side == "■" and vertical == "■"
          Surface.blit(@tileset, 2*16, 0*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == "　" and side == "　" and vertical == "　"
          Surface.blit(@tileset, 0*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == "■" and vertical == "　" and side == "　"
          Surface.blit(@tileset, 0*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif vertical == "　" and side == "■"
          Surface.blit(@tileset, 2*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif vertical == "■" and side == "　"
          Surface.blit(@tileset, 0*16, 4*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == "■" and vertical == "■" and side == "■"
          Surface.blit(@tileset, 2*16, 4*16, 16, 16, @screen, x * 32, y * 32)
        end
        # b
        diagonal = buf.get(x + 1, y - 1)
        vertical = buf.get(x, y - 1)
        side = buf.get(x + 1, y)
        if diagonal == "　" and side == "■" and vertical == "■"
          Surface.blit(@tileset, 3*16, 0*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == "　" and side == "　" and vertical == "　"
          Surface.blit(@tileset, 3*16, 2*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == "■" and vertical == "　" and side == "　"
          Surface.blit(@tileset, 3*16, 2*16, 16, 16, @screen, x * 32+ 16, y * 32)
        elsif vertical == "　" and side == "■"
          Surface.blit(@tileset, 1*16, 2*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif vertical == "■" and side == "　"
          Surface.blit(@tileset, 3*16, 4*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == "■" and vertical == "■" and side == "■"
          Surface.blit(@tileset, 1*16, 4*16, 16, 16, @screen, x * 32 + 16, y * 32)
        end
        # c
        diagonal = buf.get(x - 1, y + 1)
        vertical = buf.get(x, y + 1)
        side = buf.get(x - 1, y)
        if diagonal == "　" and side == "■" and vertical == "■"
          Surface.blit(@tileset, 2*16, 1*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif diagonal == "　" and side == "　" and vertical == "　"
          Surface.blit(@tileset, 0*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif diagonal == "■" and vertical == "　" and side == "　"
          Surface.blit(@tileset, 0*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif vertical == "　" and side == "■"
          Surface.blit(@tileset, 2*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif vertical == "■" and side == "　"
          Surface.blit(@tileset, 0*16, 3*16, 16, 16, @screen, x * 32, y * 32+ 16)
        elsif diagonal == "■" and vertical == "■" and side == "■"
          Surface.blit(@tileset, 2*16, 3*16, 16, 16, @screen, x * 32, y * 32+16)
        end
        # d
        diagonal = buf.get(x + 1, y + 1)
        vertical = buf.get(x, y + 1)
        side = buf.get(x + 1, y)
        if diagonal == "　" and side == "■" and vertical == "■"
          Surface.blit(@tileset, 3*16, 1*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif diagonal == "　" and side == "　" and vertical == "　"
          Surface.blit(@tileset, 3*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif diagonal == "■" and vertical == "　" and side == "　"
          Surface.blit(@tileset, 3*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif vertical == "　" and side == "■"
          Surface.blit(@tileset, 1*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif vertical == "■" and side == "　"
          Surface.blit(@tileset, 3*16, 3*16, 16, 16, @screen, x * 32 + 16, y * 32+ 16)
        elsif diagonal == "■" and vertical == "■" and side == "■"
          Surface.blit(@tileset, 1*16, 3*16, 16, 16, @screen, x * 32 + 16, y * 32+16)
        end

      else
        Surface.blit(@img2, 0, 0, 32, 32, @screen, x * 32, y * 32)
      end

    end # of each
  end # of each
end

@tileset = Surface.new(HWSURFACE, 64, 96, @screen.format)
Surface.blit(img, 0, 192, 64, 96, @tileset, 0, 0)

buf = "■" * (WIDTH * HEIGHT)
phase1(buf)
phase2(buf); 
while true
  # イベント取得
  while event = Event.poll
    case event
    when Event::Quit
      # ウィンドウが閉じられた等
      exit
    when Event::KeyDown
      # ...
=begin
      buf.gsub!(/■/, "a")
      buf.gsub!(/　/, "■")
      buf.gsub!(/a/, "　")
=end
    end
  end

  @screen.fill_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Gray4)
  print_buffer(buf)

  @screen.flip
#  SDL.delay(15)
  SDL.delay(500)
      phase2(buf)
end  
