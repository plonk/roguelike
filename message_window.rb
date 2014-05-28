# -*- coding: utf-8 -*-
class MessageWindow
  COLOR_KEY = [0,0,0x40]
  TEXT_COLOR = [255,255,255]
  BACKGROUND_COLOR = [0, 0, 128]
  attr_accessor :auto_hide
  LEFT_MARGIN = 20
  TOP_MARGIN = 4
  @@instance = nil
  CLEAR = true

  def MessageWindow.open
    if @@instance
      @@instance.reset
      return @@instance 
    end
    @@instance = MessageWindow.new
  end

  def initialize
    raise "singleton MessageWindow already initialized" if @@instance

    # @window は半透明のウィンドウ
    @window = Surface.new(HWSURFACE|SRCALPHA, 600, 80, $screen.format)
    @window.set_alpha(SRCALPHA, 192)
    @window.fill_rect(0, 0, 600, 80, BACKGROUND_COLOR)

    @buf = Surface.new(HWSURFACE, 550, 64, $screen.format)
    @buf.set_color_key(SRCCOLORKEY, COLOR_KEY)

    @font = TTF.open("VLGothic/VL-Gothic-Regular.ttf", 27)
    @show_until = nil
    @auto_hide = true
    @triangle = Surface.load("data/triangle_down.png")
    @additional_pages = []
    @clear_flag = true
    reset
  end

  # 文字列先頭のフォームフィード("\C-l" "\f" ^L)
  # で瞬時に改頁を行う？
  def set_text(text)
    reset
    @cur_page = text
    show
  end

  def add_page(text)
    if @clear_flag 
      @clear_flag = false
      return set_text(text) 
    end

    if @cur_page
      if @scrolling # すでにスクロール中なのでキューに保存するだけ
        @additional_pages << text
        return
      else
        @old_page = @cur_page
        @cur_page = text
        @scrolling = true
        @scroll_onset = $frame_count
      end
    else
      @cur_page = text
      show
    end
  end

  def reset
    @cur_page = nil
    @old_page = nil
    @scrolling = false
    @scroll_onset = nil
  end

  def scrolling?
    @scrolling
  end

  def draw
    return unless @show_until # まだ何も表示したことがない
    if not @scrolling and @show_until < $frame_count and @auto_hide
      reset
      return
    end
    if @scrolling
      x = ($frame_count - @scroll_onset) * 2
      if x >= 64
        if @additional_pages.any?
          # スクロールを続ける
          @old_page = @cur_page
          @cur_page = @additional_pages.shift
          @scroll_onset = $frame_count
          return draw
        else
          @scrolling = false
          @scroll_onset = nil
          # スクロールが停止してから
          show #  2 秒間ウィンドウを表示しつづける
          return draw
        end
      end
      @buf.fill_rect(0, 0, 550, 64, COLOR_KEY)
      @old_page.split(/\n/).each_with_index do |line, i|
        @font.draw_blended_utf8(@buf, line, 0, 32*i - x, *TEXT_COLOR)
      end
      @cur_page.split(/\n/).each_with_index do |line, i|
        @font.draw_blended_utf8(@buf, line, 0, 32*i + 64 - x, *TEXT_COLOR)
      end
    else
      @buf.fill_rect(0, 0, 550, 64, COLOR_KEY)
      @cur_page.split(/\n/).each_with_index do |line, i|
        @font.draw_blended_utf8(@buf, line, 0, 32*i, *TEXT_COLOR)
      end
    end
    $screen.put(@window, 20, 375)
    $screen.put(@buf, 20+LEFT_MARGIN, 375+TOP_MARGIN)

    if not @auto_hide
      # メッセージ送り用の三角形を点滅させる
      $screen.put(@triangle, 320 - 16, 440) if $frame_count / 15 % 2 == 0
    end
  end

  def show
    @show_until = $frame_count + 2*FPS
  end

  def hide
    @show_until = $frame_count
  end

  def clear
    @clear_flag = true
  end
end

if __FILE__ == $0
  load "./test13.rb"
end
