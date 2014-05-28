# -*- coding: utf-8 -*-
# エフェクトモジュール

module Effects
  @@surface = nil
  @@effect_list = nil

  # エフェクトモジュールの初期化
  # surface に描画される(通常 Screen)
  def Effects.init(surface)
    @@surface = surface
    @@effect_list = Array.new
  end

  # 描画対象の Surface
  def Effects.surface
    @@surface
  end

  # 爆発エフェクトを開始する
  def Effects.start_explosion(gzero_x, gzero_y)
    register( Explosion.new(gzero_x, gzero_y) )
  end

  # めぐすり草のエフェクトを開始する
  def Effects.start_ring(gzero_x, gzero_y)
    register( Ring.new(gzero_x, gzero_y) )
  end

  # 罠もわっ
  def Effects.start_smoke(gzero_x, gzero_y)
    register( Smoke.new(gzero_x, gzero_y) )    
  end

  # 何らかのエフェクトが走っているか？
  def Effects.busy?
    @@effect_list.any?
  end

  # メインループで呼び出してください
  def Effects.draw
    @@effect_list.each do |e|
      e.draw
    end
  end

  private

  def Effects.register(e)
    # assert(e.is_a? Effect)
    @@effect_list << e
  end

  def Effects.unregister(e)
    @@effect_list.delete(e)
  end

  class Explosion
    def initialize(x, y)
#      @image = Surface.load("data/explosion.png")
      # @image = Surface.new(HWSURFACE|SRCALPHA,
      #                            SCREEN_WIDTH, SCREEN_HEIGHT, $screen.format)
      @image = Surface.load("data/explosion.bmp")
      @image.set_color_key(SRCCOLORKEY, @image.get_pixel(0,0))
      @count = 0
      @dead_p = false

      @x, @y = [x, y]
    end

    def draw
      raise "draw method called of dead effect" if @dead_p

#      Effects.surface.put(@image, @x, @y)
      @image.set_alpha(SRCALPHA, 255 - (255.to_f / 90)*@count)
      scale = 1 + @count.to_f / (90/3)
      image_width = @image.w.to_f * scale
      image_height = @image.h.to_f * scale
      # 元画像の中央を中心として 90 フレームで1回転させながら
      # 拡大してゆく
      Surface.transform_blit(@image, Effects.surface,
#0,
                             @count*4, # [0,360]
                             scale, scale,
                             @image.w/2, @image.h/2,
                             @x, @y,
                             0x00)

      @count += 1
      if @count == 90
        Effects.unregister(self)
      end
    end
  end

  class Ring
    BLACK = [0, 0, 0]
    END_TIME = 90
    RING_COLOR = [255,255,255]
    SPEED = 5 # ... ピクセル毎フレームの速度で広がる

    def initialize(x, y)
      @surface = Effects.surface
      @x, @y = [x, y]
      # 対象 Surface と同じ大きさの Surface を用意する
      @canvas = Surface.new(HWSURFACE|SRCCOLORKEY, @surface.w, @surface.h, @surface.format)
      @canvas.set_color_key(SRCCOLORKEY, BLACK)
      @count = 0
    end

    def draw
      @canvas.draw_circle(@x, @y, @count*SPEED, RING_COLOR, true, false)
      if @count >= 10
        @canvas.draw_circle(@x, @y, @count*SPEED - 10, BLACK, true, false)
      end

      @surface.put(@canvas, 0, 0)

      @count += 1
      if @count == 90
        Effects.unregister(self)
      end
    end
  end

  class Particle
    def self.init
      @@particles = []
    end

    def self.add(part)
      @@particles << part
    end

    def self.update
      dead_list = []
      @@particles.each do |part|
        # calculate position
        part.x += part.energy * Math.cos(part.angle * Math::PI / 180)
        part.y += part.energy * -Math.sin(part.angle * Math::PI / 180)
        # パーティクルの中心が画面から 50 px 以上離れたら消失させる
        if part.x < -50 or part.x >= 640+50 or
            part.y < -50 or part.y >= 480+50
          dead_list << part
          next
        end

        # decrease momentum
        part.energy *= 0.99

        # 大きさの変化
        part.size *= 1.01

        # 角度の変化
        part.angle *= 1.00

        # alpha 値を下げる
        part.alpha *= 0.96

      end
      dead_list.each do |part|
        @@particles.delete part
      end
    end

    def self.draw(surface)
      @@particles.reverse_each do |part|
        surface.draw_circle(part.x, part.y, part.size.round, part.color,
                            true, false, part.alpha)
        if false and part.size > 1
          surface.draw_circle(part.x, part.y, part.size.round, [0,0,0],
                              false, true)
        end
      end
    end

    def self.objnum
      @@particles.size
    end

    attr_accessor :x, :y, :angle, :energy, :color, :size, :alpha
    def initialize(x, y, angle, energy, color, alpha)
      @x = x
      @y = y
      @angle = angle
      @energy = energy
      @color = color
      @size = 10 # 円の半径
      @alpha = alpha
    end
  end

  class Smoke
    def initialize(x, y)
      @x, @y = [x, y]
      @count = 0
      Particle.init

      color = [255,255,255]
      alpha = 64
      10.times do
        energy = 0.2 * rand # [0,1]  + rand * 5
        angle = (rand * 360).to_i
        x = @x - 10 + 20*rand
        y = @y - 10 + 20*rand
        part = Particle.new(x, y, angle, energy, color, alpha)
        Particle.add(part)
      end
    end

    def draw
      # Effects.surface.draw_circle(@x, @y, 10, [255,255,255], true, false, 128 - 128.0/90*@count)
      Particle.update
      Particle.draw(Effects.surface)
      @count += 1
      if @count == 90
        Effects.unregister(self)
      end
    end
  end
end
