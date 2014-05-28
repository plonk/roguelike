# -*- coding: utf-8 -*-
require_relative 'autotile'

class DungeonBackground
  def initialize
    load_resources
  end

  def load_resources
    # 壁タイル用
    img = Surface.load('data/Dungeon_A1.png')
    # 床タイル用
    @img2 = Surface.load("data/Dungeon_A2.png")

    @background = Surface.new(HWSURFACE, WIDTH*32, HEIGHT*32, $screen.format)

    @tileset = Surface.new(HWSURFACE, 64, 96, $screen.format)
    Surface.blit(img, 0, 192, 64, 96, @tileset, 0, 0)
    @autotile = Autotile.new(@tileset)
  end


  def update(map)
    (0...HEIGHT).each do |y|
      (0...WIDTH).each do |x|
        if map.get(x, y) == WALL
          tile = @autotile.wall(map.atinfo(x, y))
          Surface.blit(tile, 0, 0, 32, 32, @background, x * 32, y * 32)
        else
          # 床
          Surface.blit(@img2, 0, 0, 32, 32, @background, x * 32, y * 32)
        end
      end # of each
    end
  end

  def surface
    @background
  end

  def draw(x, y, dest)
    Surface.blit(surface, x, y, 640, 480, dest, 0, 0)
  end
end
