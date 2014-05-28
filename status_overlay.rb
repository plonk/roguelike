# -*- coding: utf-8 -*-
# HP バー
# 	HP 200 まで
# 		HP 1 ポイントあたり 2 ピクセル
# 	200 以上は 最大HP を 400 ピクセルとする
# 	緑[0,255,0], 赤[255,0,0]
# 	外枠(白) 2 ピクセル
# 	高さ 11 ピクセル
# 満腹度バー
# 	高さ 3 ピクセル、幅 162 ドット
# 	水色 [63, 63, 254] と 黒 (なんだけど見難いから工夫したい)
# 	外枠(白) 2 ピクセル
# 外枠が 1 ドット上下に重なってる
# 「HP」の位置にあわせると良いと思います。

class StatusOverlay
  HP_BAR_X = 275
  HP_BAR_Y = 35
  HP_BAR_HEIGHT = 11

  TUMMY_BAR_X = HP_BAR_X
  TUMMY_BAR_Y = HP_BAR_Y + HP_BAR_HEIGHT + 3
  TUMMY_BAR_HEIGHT = 3
  TUMMY_FACTOR = 162


  def initialize(scene)
    @scene = scene
    @overlay_osd = OSD_Large.new(0, 0, true)
  end

  def update(floor_level, pc)
    # "    1階   Lv 1       HP 15/15            0 G"
    @overlay_osd.set_text2("    ",
                           floor_level,
                           [" 階","skyblue"],
                           ["   Lv ","skyblue"],
                           pc.level,
                           ["    HP ", "skyblue"],
                           "%3d" % pc.hp,
                           ["/","skyblue"],
                           "%3d" % pc.max_hp,
                           ["     ","skyblue"],
                           "%8d" % pc.gold,
                           [" G","skyblue"])
    @max_hp_width = pc.max_hp * 2
    @hp_width = pc.hp * 2
  end

  def draw
    @overlay_osd.draw

    draw_hp_bar
    draw_tummy_bar
  end

  def draw_hp_bar
    # 外枠を描く
    $screen.fill_rect(HP_BAR_X-2, HP_BAR_Y-2, @max_hp_width+4, HP_BAR_HEIGHT+4, [255,255,255])

    $screen.fill_rect(HP_BAR_X, HP_BAR_Y, @hp_width, HP_BAR_HEIGHT, [0,255,0])
    $screen.fill_rect(HP_BAR_X+@hp_width, HP_BAR_Y,
                      @max_hp_width - @hp_width, HP_BAR_HEIGHT, [255,0,0])
  end

  def draw_tummy_bar
    max_tummy_width = (1.0 * TUMMY_FACTOR).to_i # とりえず最大満腹度100%だということにする
    tummy_width = (0.95 * TUMMY_FACTOR).to_i # とりあえず(ry

    # 外枠を描く
    $screen.fill_rect(TUMMY_BAR_X-2, TUMMY_BAR_Y-2,
                      max_tummy_width+4, TUMMY_BAR_HEIGHT+4, [255,255,255])

    $screen.fill_rect(TUMMY_BAR_X, TUMMY_BAR_Y, tummy_width, TUMMY_BAR_HEIGHT, [63, 63, 254])
    $screen.fill_rect(TUMMY_BAR_X+tummy_width, TUMMY_BAR_Y, max_tummy_width - tummy_width, TUMMY_BAR_HEIGHT, [0, 0, 0])
  end
end
