# -*- coding: utf-8 -*-
require 'sdl'
include SDL

require_relative 'map'
require_relative 'rgb_db'
require_relative 'rectangle'

Encoding.default_external = "utf-8"

require_relative 'mylib'
require_relative 'chip'
require_relative 'motion'
require_relative "osd"
require_relative 'window'
require_relative 'game_object'


class Camera
  def initialize
    @x_origin = 0
    @y_origin = 0
    @window_w = SCREEN_WIDTH
    @window_h = SCREEN_HEIGHT
  end
end

require_relative 'scene'
require_relative 'title'
require_relative 'dungeon'
require_relative 'settings'
require_relative 'input'

class Game
  def initialize
    SDL.init( INIT_VIDEO|INIT_JOYSTICK|INIT_AUDIO )
    Input.init
    TTF.init
#    $screen = Screen.open(SCREEN_WIDTH, SCREEN_HEIGHT, 0, HWSURFACE | FULLSCREEN)
    $screen = Screen.open(SCREEN_WIDTH, SCREEN_HEIGHT, 0, HWSURFACE)
    WM.set_caption(__FILE__, "")
    Sound.init
#    Settings.load
  end


  def run
    @scene = TitleScene.new
#    @scene = DungeonScene.new

    main_loop do
      # イベントを処理させる
      while event = Event.poll
        @scene.event_handler(event)
      end 

      Input.scan
      next_scene = @scene.draw

      # シーン遷移が要求された
      if next_scene
        # 別のシーンオブジェクトを作る
        @scene = next_scene.new
      end
    end
  end
end

if __FILE__ == $0
  game = Game.new
  game.run
end
