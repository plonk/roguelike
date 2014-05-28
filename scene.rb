# -*- coding: utf-8 -*-
require_relative 'osd'

class Scene
  # MUSIC_VOLUME = 64
  MUSIC_VOLUME = 0

  def initialize
    @osd = OSD.new(0, 480-20)
    # 画面を暗くする用の半透明の黒いサーフェス
    @black_surface = Surface.new(HWSURFACE|SRCALPHA,
                                 SCREEN_WIDTH, SCREEN_HEIGHT, $screen.format)
    # @black_surface.set_alpha(SRCALPHA, 128)
    Mixer.set_volume_music(MUSIC_VOLUME)

    toggle_mute(true) if $DEBUG
  end

  # should be called last
  def draw
    @osd.draw
  end

  def draw_dimmer
    $screen.put(@black_surface, 0, 0)
  end

  def fade_out
    # Mixer::fade_out_music(200)
    screenshot  = $screen.copy_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    i = 16
    main_loop do 
      $screen.put(screenshot, 0, 0)
      @black_surface.set_alpha(SRCALPHA, i-1)
      draw_dimmer
      i += 16
      break if i > 255
    end
    # @black_surface.set_alpha(SRCALPHA, 128)
  end

  def fade_in
    i = 255
    main_loop do 
      break if i < 0
      draw
      @black_surface.set_alpha(SRCALPHA, i)
      draw_dimmer
      i -= 16
    end
    # @black_surface.set_alpha(SRCALPHA, 128)
  end

  def quit_main_loop
    raise "quit_main_loop"
  end

  def toggle_mute(mute = nil)
    if mute == nil
      mute = !@muted_p
    end

    if mute
      Mixer.set_volume_music(0)
      @osd.set_text("ミュート")
    else
      Mixer.set_volume_music(MUSIC_VOLUME)
      @osd.set_text("ミュート解除")
    end
    @muted_p = mute
  end

  # イベントを処理したら true、
  # 処理しなかったら false を返す。
  def event_handler(event)
    case event
    when Event::Quit
      # ウィンドウが閉じられた等
      exit
    when Event::KeyDown
      case event.sym 
      when SDL::Key::M          # BGM のミュート
        toggle_mute
      when SDL::Key::F          # 1フレームの処理にかかった時間の表示
        msg = sprintf "%d msec elapsed in previous frame", $time_elapsed_in_frame * 1000
        @osd.set_text(msg)
      else
        return false
      end
    else
      return false
    end
    return true
  end

  def fill_screen(color)
    raise unless color.is_a? Array
    $screen.fill_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, color)
  end
end
