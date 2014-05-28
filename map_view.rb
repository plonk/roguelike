# -*- coding: utf-8 -*-
class MapView
  def initialize
    @overlay = Surface.new(HWSURFACE, 640, 480, $screen.format)
    @overlay.fill_rect(0, 0, 640, 480, [0,0,0])
    @overlay.set_color_key(SRCCOLORKEY, @overlay.get_pixel(0,0))
    @overlay.set_alpha(SRCALPHA, 128)

  end

  def surface
    @overlay
  end

  def render(map)
    map_surface = Surface.new(HWSURFACE, WIDTH*8, HEIGHT*8, $screen.format)
    (0...WIDTH).each do |x|
      (0...HEIGHT).each do |y|
        #        next if x == 0 or y == 0
        #        next if x == WIDTH-1 or y == HEIGHT-1
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
end
