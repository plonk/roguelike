# -*- coding: utf-8 -*-
class MapView
  def initialize
    @overlay = Surface.new(HWSURFACE, 640, 480, $screen.format)
    @overlay.fill_rect(0, 0, 640, 480, [0,0,0])
    @overlay.set_color_key(SRCCOLORKEY, @overlay.get_pixel(0,0))
    @overlay.set_alpha(SRCALPHA, 128)

    load_resources
  end

  def load_resources
    @map_hero1 = load_png("data/map_hero1.png")
    @map_hero2 = load_png("data/map_hero2.png")
    @map_enemy = load_png("data/map_enemy.png")
    @map_exit = load_png("data/map_exit.png")
    @map_item = load_png("data/map_item.png")
    @map_trap = load_png("data/map_trap.png")
  end

  def surface
    @overlay
  end

  def render(map)
    map_surface = Surface.new(HWSURFACE, WIDTH*8, HEIGHT*8, $screen.format)
    (0...WIDTH).each do |x|
      (0...HEIGHT).each do |y|
        s = map[x, y]
        if s == FLOOR
          map_surface.fill_rect(x*8, y*8, 8, 8, [0, 0, 255])
        elsif s == WALL

          # 左上
          map_surface.fill_rect(x*8, y*8, 2, 2, [255, 255, 255]) if map[x-1,y-1] == FLOOR
          # 上
          map_surface.fill_rect(x*8, y*8, 8, 2, [255, 255, 255]) if map[x,y-1] == FLOOR
          # 右上
          map_surface.fill_rect(x*8+6, y*8, 2, 2, [255, 255, 255]) if map[x+1,y-1] == FLOOR
          # 左
          map_surface.fill_rect(x*8, y*8, 2, 8, [255, 255, 255]) if map[x-1,y] == FLOOR
          # 右
          map_surface.fill_rect(x*8+6, y*8, 2, 8, [255, 255, 255]) if map[x+1,y] == FLOOR
          # 左下
          map_surface.fill_rect(x*8, y*8+6, 2, 2, [255, 255, 255]) if map[x-1,y+1] == FLOOR
          # 下
          map_surface.fill_rect(x*8, y*8+6, 8, 2, [255, 255, 255]) if map[x,y+1] == FLOOR
          # 右下
          map_surface.fill_rect(x*8+6, y*8+6, 2, 2, [255, 255, 255]) if map[x+1,y+1] == FLOOR

        end
      end
    end
    @overlay.put(map_surface, (640 - WIDTH*8) / 2, (480 - HEIGHT*8) / 2)
  end

  def draw(translucent, player, objects)
    if translucent
      $screen.put(@overlay, 0, 0)
    else
      # アルファ値やカラーキーを使わずに描画する
      # スペースバーが押され、マップのみが表示されている状態
      Surface.transform_draw(@overlay, $screen, 0,
                             1, 1,
                             0, 0, 0, 0,
                             0)
    end

    # 下のもの
    objects.each do |o|
      if o.is_a? Exit
        $screen.put(@map_exit,
                    (640 - WIDTH*8)/2 + o.xpos*8,
                    (480 - HEIGHT*8)/2 + o.ypos*8)
      elsif o.is_a? Trap and (player.has_state?(:yokumie) or o.visible?)
        # 罠は可視の場合のみ表示する
        $screen.put(@map_trap,
                    (640 - WIDTH*8)/2 + o.xpos*8,
                    (480 - HEIGHT*8)/2 + o.ypos*8)
      elsif o.is_a? Item
        $screen.put(@map_item,
                    (640 - WIDTH*8)/2 + o.xpos*8,
                    (480 - HEIGHT*8)/2 + o.ypos*8)
      else
      end
    end
    # それに乗るもの
    objects.each do |o|
      if o.is_a? Enemy
        $screen.put(@map_enemy,
                    (640 - WIDTH*8)/2 + o.xpos*8,
                    (480 - HEIGHT*8)/2 + o.ypos*8)
      end
    end
    # 主人公の居る場所
    hero = @map_hero2
    if $frame_count % 60 < 30
      hero = @map_hero1
    end
    $screen.put(hero,
                (640 - WIDTH*8)/2 + player.xpos*8,
                (480 - HEIGHT*8)/2 + player.ypos*8)
  end
end
