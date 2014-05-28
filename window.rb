# -*- coding: utf-8 -*-
require_relative 'sound'

class Window
  def initialize(x = 50, y = 50)
    @font = Kanji.open("k14-2000-1.bdf", 14)
    @font.add("a14.bdf")
    @font.set_coding_system(Kanji::SJIS)

    @foreground = get_color("white")
    @background = get_color("blue4")
    @duration = 0 
    @default_duration = 2 * 60
    @text = "(n/a)"

    @x = x
    @y = y
  end

  def set_text(str)
    @text = str
    @duration = @default_duration
  end

  def show
    @duration = @default_duration
  end

  def hide
    @duration = 0
  end

  def draw
    if @duration > 0
      sjis = @text.encode("CP932")
      width = @font.textwidth(sjis) + 8
      height = @font.height + 4
      $screen.fill_rect(@x, @y, width, height, @background)
      @font.put($screen, sjis, @x + 4, @y + 2, *@foreground)
      #      @duration -= 1
    end
  end
end

class Menu
  LEFT_MARGIN = 32 + 4 # 矢印アイコンもここに入る
  RIGHT_MARGIN = 8 + 32
  TOP_MARGIN = 5
  BOTTOM_MARGIN = 8
  X = 50
  Y = 50 
  WIDTH = 400
  HEIGHT = 320 # 32 の倍数にしよう
  LINE_HEIGHT = 32
  def initialize
    @font = TTF.open("VLGothic/VL-Gothic-Regular.ttf", 27)
    @cursor = Surface.load("data/menu_cursor.png")
    @cursor_pos = 0
    @selection = nil
    @list = []
    @x = X
    @y = Y
    @width = WIDTH
    @height = HEIGHT
    @visibility = true
    @blank_surface = prepare_blank_surface
 end

  def set_position(x, y)
    @x = x
    @y = y
  end

  def prepare_blank_surface
    s = Surface.new(HWSURFACE, @width, @height, $screen.format)
    s.set_alpha(SRCALPHA, 192)
    s.fill_rect(0, 0, @width, @height, [0,0,128])

    # 内周に1ドットの白線を引く
    r = @width-1
    b = @height-1
    s.draw_line(0, 0, r, 0, [255,255,255])
    s.draw_line(r, 0, r, b, [255,255,255])
    s.draw_line(0, b, r, b, [255,255,255])
    s.draw_line(0, 0, 0, b, [255,255,255])
    return s
  end
  private :prepare_blank_surface

  def set_size(width, height)
    @width = width
    @height = height
    @blank_surface = prepare_blank_surface
  end

  def visible?
    @visibility
  end

  def hide
    @visibility = false
  end

  def add_item(label, &block)
    @list << [label, block]
    recalc_window_size
  end

  def recalc_window_size
    nitems = @list.size
    @width = @list.map { |label, block|
      @font.text_size(label)[0] }.max + LEFT_MARGIN + RIGHT_MARGIN
    @height = nitems * 32 + TOP_MARGIN + BOTTOM_MARGIN
    @blank_surface = prepare_blank_surface
  end

  def select(index)
    raise unless (0..(@list.size - 1)).include? index
    @cursor_pos = index
    @selection = @list[index]
  end

  def unselect
    @selection = nil
  end

  def reset_pos
    @cursor_pos = 0
  end

  def update
    max_pos = @list.size - 1
    if Input.triggered? Key::DOWN
      @cursor_pos += 1
      Sound.beep
    elsif Input.triggered? Key::UP
      @cursor_pos -= 1
      Sound.beep
    end
    @cursor_pos = max_pos if @cursor_pos < 0
    @cursor_pos = 0 if @cursor_pos > max_pos # 最下行で下に入力すると最上行に戻る
    if Input.triggered? Key::Z
      Sound.beep
      # 決定キーによりアイテムが選択された
      block = @list[@cursor_pos][1]
      block.call
    elsif Input.triggered? Key::A
      @visibility = false
      Sound.beep
    end
  end

  def draw
    # 描画
    $screen.put(@blank_surface, @x, @y)

    @list.each_with_index do |row, i|
      @font.draw_blended_utf8($screen, row[0],
                              @x + LEFT_MARGIN, @y + TOP_MARGIN + i * LINE_HEIGHT,
                              *[255,255,255])
    end
    wobble = 2*(Math.sin($frame_count.to_f/3))
    $screen.put(@cursor, @x + 3 + wobble, @y + TOP_MARGIN + @cursor_pos*LINE_HEIGHT)
  end
end
