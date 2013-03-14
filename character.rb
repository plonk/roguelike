# -*- coding: utf-8 -*-
require 'sdl'
include SDL

require "./map.rb"
require './rgb_db.rb'
require './rectangle.rb'

Encoding.default_external = "utf-8"

require './mylib.rb'

require './chip.rb'

require "./motion.rb"

require "./osd.rb"
require './window.rb'

require './game_object.rb'


class Camera
  def initialize
    @x_origin = 0
    @y_origin = 0
    @window_w = SCREEN_WIDTH
    @window_h = SCREEN_HEIGHT
  end
end

require './scene.rb'

require './title.rb'
require './dungeon.rb'

require './settings.rb'

require './input.rb'

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
