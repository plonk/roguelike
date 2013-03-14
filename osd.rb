# -*- coding: utf-8 -*-

class OSD
  attr_accessor :duration
  DEFAULT_DURATION = 3*FPS
  COLOR_KEY = [0,255,0]

  def initialize(x = 0, y = 0, forever = false)
    @x = x
    @y = y

    @font = Kanji.open("k14-2000-1.bdf", 14)
    @font.add("A14.bdf")
    @font.set_coding_system(Kanji::SJIS)

    @color = "white"
    @duration = DEFAULT_DURATION
    @text = "(n/a)"

    @forever_p = forever
    @blink_p = false

    @source = Surface.new(HWSURFACE, 640, 17, $screen.format)
    @scale_x = 1.0
    @scale_y = 1.0
    @scaled = nil
  end

  def blink?; @blink_p end
  def blink=(value)
    @blink_p = value ? true : false
  end

  def set_text(str)
    set_text2([str, @color])
  end

  def show
    @duration = DEFAULT_DURATION
  end

  def hide
    @duration = 0
  end

  def render_source_surface
    @source.fill_rect(0, 0, 640, 17, COLOR_KEY)
    x = 4
    y = 2
    @text.each do |text, color|
      (x-1..x+1).each do |xx|
        (y-1..y+1).each do |yy|
          next if x == xx and y == yy
          @font.put(@source, text, xx, yy, *[0,0,0])
        end
      end
      @font.put(@source, text, x, y, *color)
      x += @font.textwidth(text)
    end
    @scaled = @source.transform_surface(COLOR_KEY, 0, @scale_x, @scale_y, 0)
    @scaled.set_color_key(SRCCOLORKEY, COLOR_KEY)
  end


  def set_scale(x, y)
    @scale_x = x
    @scale_y = y
    render_source_surface
  end

  def get_scale
    [@scale_x, @scale_y]
  end

  def draw
    return unless @scaled # テキストがセットされていない
    sjis = @text
    if @duration > 0
      $screen.put(@scaled, @x, @y)
      # Surface.blit(@scaled, 0,0,0,0,
      #              $screen, @x,@y)
    end
    @duration -= 1 unless @forever_p
    if @blink_p and @duration == -30
      @duration = DEFAULT_DURATION
    end
  end

  def set_text2(*args)
    @text = args.map { |a|
      if a.is_a? Array
        [a[0].encode("CP932"), get_color(a[1])]
      else
        [a.to_s, [255,255,255]]
      end
    }
    @duration = DEFAULT_DURATION
    render_source_surface
  end
end

class OSD_Large < OSD
  def initialize(x = 0, y = 0, forever = true)
    super
    @scale_x = @scale_y = 2.0
  end
end
