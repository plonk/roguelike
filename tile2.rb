# -*- coding: utf-8 -*-
require 'sdl'
include SDL

White = [255,255,255]
Black = [0, 0, 0]
Gray = [168, 168, 168]
Gray2 = [128, 128, 128]
Gray4 = [64, 64, 64]
Green = [0,128,128]
Yellow = [255, 250, 205]

WIDTH = 40
HEIGHT = 30
#WIDTH = 20
#HEIGHT = 15
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

require './cell_automaton.rb'

@tileset = Surface.new(HWSURFACE, 64, 96, @screen.format)
Surface.blit(img, 0, 192, 64, 96, @tileset, 0, 0)

buf = "," * (WIDTH * HEIGHT)
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
