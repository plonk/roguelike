# -*- coding: utf-8 -*-

class InventoryWindowController
  def initialize
    @duration = 0
  end

  def down?
    # 押し下げられて 300msec 後に 100msec ずつリピートする
    # なんらかのリピートメカニズムを入力モジュール側に用意するべきでは
    # なかろうか
    if Input.triggered? Key::DOWN or Input.pressed?(Key::DOWN, @duration)
      if Input.triggered?(Key::DOWN)
        @duration = 0.3 
      else
        @duration += 0.05
      end
      true
    else
      false
    end
  end

  def up?
    if Input.triggered? Key::UP or Input.pressed?(Key::UP, @duration)
      if Input.triggered?(Key::UP)
        @duration = 0.3
      else
        @duration += 0.05
      end
      true
    else
      false
    end
  end

  def select?
    Input.triggered? Key::Z
  end
end

class InventoryWindow
  LEFT_MARGIN = 32 + 4
  TOP_MARGIN = 5
  X = 50
  Y = 50 
  WIDTH = 400
  HEIGHT = 300

  def initialize(inventory)
    @font = TTF.open("VLGothic/VL-Gothic-Regular.ttf", 27)
    @cursor = Surface.load("data/menu_cursor.png")
    @cursor_pos = 0
    @selection = nil
    @inventory = inventory
    @controller = InventoryWindowController.new
  end

  def reset
    @cursor_pos = 0
    @selection = nil
  end

  def draw
    list = @inventory
    if @inventory.any?
      max_pos = list.size - 1

      if @controller.select?
        Sound.beep
        # 決定キーによりアイテムが選択された
        @selection = list[@cursor_pos]
      elsif @controller.down?
        @cursor_pos += 1
        Sound.beep
      elsif @controller.up?
        @cursor_pos -= 1
        Sound.beep
      end
      @cursor_pos = max_pos if @cursor_pos < 0
      @cursor_pos = 0 if @cursor_pos > max_pos

      $screen.fill_rect(X, Y, WIDTH, HEIGHT, [0,0,128])
      list.each_with_index do |row, i|
        @font.draw_blended_utf8($screen, row.to_s,
                                X + LEFT_MARGIN, Y + TOP_MARGIN + i * 32, *[255,255,255])
      end
      wobble = 2*(Math.sin($frame_count.to_f/3))
      $screen.put(@cursor, X + wobble, Y + TOP_MARGIN + @cursor_pos*32)
    else
      # 持ち物欄は空です
      $screen.fill_rect(X, Y, WIDTH, HEIGHT, [0,0,128])
      @font.draw_blended_utf8($screen, "(何も持っていません)",
                              X + LEFT_MARGIN, Y + TOP_MARGIN, *[255,255,255])
    end
  end

  # 選択された項目がある
  def selected?
    @selection ? true : false
  end

  # 選択された項目
  def selection
    @selection
  end
end
