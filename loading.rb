# -*- coding: utf-8 -*-
# ロード中であることを表示するシーン
class LoadingScene < Scene
  def initialize(message = "(ダンジョンの名前)")
    @win = Window.new(SCREEN_WIDTH / 2 - 60, SCREEN_HEIGHT / 2 - 14/2)
    @win.set_text(message)
    super()
    @fcount = 0
    @end_fcount = 1 * FPS
    @alive_p = true
  end
  
#    show_message

  def draw
    fill_screen [0,0,0]
    @win.draw
    @fcount += 1

    if @fcount == @end_fcount
      fade_out
#      quit_main_loop 
      return DungeonScene
    end
    return nil
  end
end
