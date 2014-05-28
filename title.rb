# -*- coding: utf-8 -*-
require_relative 'loading'

class TitleScene < Scene
  # タイトル画面表示に向けての初期化
  def initialize
    super

    @openning_music = Mixer::Music.load("data/tw017.mp3")
    @title_image = Surface.load("data/title.png")
    @title_osd = OSD.new(320 - 80, 240 - 7)
    @title_osd.set_text("Hit Space to Start")
    @title_osd.blink = true
    Mixer::fade_in_music(@openning_music, -1, 0)
    @next_scene = nil
  end

  # イベントが処理され、さらなる処理が必要ないと思しき時は
  # true を返す
  # event_handler

  def draw
    $screen.put(@title_image, 0, 0)
    @title_osd.draw
    super

    if Input.triggered? Key::SPACE
      fade_out
      @next_scene = LoadingScene
    end

    @next_scene
  end
end

