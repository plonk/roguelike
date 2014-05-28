# -*- coding: utf-8 -*-
class Autotile
  def initialize(tileset)
    @autotile_wall = []
    init_autotile(tileset)
  end

  # @autotile_wall を初期化する
  def init_autotile(tileset)
    (0..255).each do |id|
      tile = Surface.new(HWSURFACE, 32, 32, $screen.format)

      # ab
      # cd

      # a
      diagonal = Map.is_wall_or_floor?(id, NORTHWEST)
      vertical = Map.is_wall_or_floor?(id, NORTH)
      side = Map.is_wall_or_floor?(id, WEST)
      if diagonal == FLOOR and side == WALL and vertical == WALL
        Surface.blit(tileset, 2*16, 0*16, 16, 16, tile, 0, 0)
      elsif diagonal == FLOOR and side == FLOOR and vertical == FLOOR
        Surface.blit(tileset, 0*16, 2*16, 16, 16, tile, 0, 0)
      elsif diagonal == WALL and vertical == FLOOR and side == FLOOR
        Surface.blit(tileset, 0*16, 2*16, 16, 16, tile, 0, 0)
      elsif vertical == FLOOR and side == WALL
        Surface.blit(tileset, 2*16, 2*16, 16, 16, tile, 0, 0)
      elsif vertical == WALL and side == FLOOR
        Surface.blit(tileset, 0*16, 4*16, 16, 16, tile, 0, 0)
      elsif diagonal == WALL and vertical == WALL and side == WALL
        Surface.blit(tileset, 2*16, 4*16, 16, 16, tile, 0, 0)
      end
      # b
      diagonal = Map.is_wall_or_floor?(id, NORTHEAST)
      vertical = Map.is_wall_or_floor?(id, NORTH)
      side = Map.is_wall_or_floor?(id, EAST)
      if diagonal == FLOOR and side == WALL and vertical == WALL
        Surface.blit(tileset, 3*16, 0*16, 16, 16, tile, 16, 0)
      elsif diagonal == FLOOR and side == FLOOR and vertical == FLOOR
        Surface.blit(tileset, 3*16, 2*16, 16, 16, tile, 16, 0)
      elsif diagonal == WALL and vertical == FLOOR and side == FLOOR
        Surface.blit(tileset, 3*16, 2*16, 16, 16, tile, 16, 0)
      elsif vertical == FLOOR and side == WALL
        Surface.blit(tileset, 1*16, 2*16, 16, 16, tile, 16, 0)
      elsif vertical == WALL and side == FLOOR
        Surface.blit(tileset, 3*16, 4*16, 16, 16, tile, 16, 0)
      elsif diagonal == WALL and vertical == WALL and side == WALL
        Surface.blit(tileset, 1*16, 4*16, 16, 16, tile, 16, 0)
      end
      # c
      diagonal = Map.is_wall_or_floor?(id, SOUTHWEST)
      vertical = Map.is_wall_or_floor?(id, SOUTH)
      side = Map.is_wall_or_floor?(id, WEST)
      if diagonal == FLOOR and side == WALL and vertical == WALL
        Surface.blit(tileset, 2*16, 1*16, 16, 16, tile, 0, 16)
      elsif diagonal == FLOOR and side == FLOOR and vertical == FLOOR
        Surface.blit(tileset, 0*16, 5*16, 16, 16, tile, 0, 16)
      elsif diagonal == WALL and vertical == FLOOR and side == FLOOR
        Surface.blit(tileset, 0*16, 5*16, 16, 16, tile, 0, 16)
      elsif vertical == FLOOR and side == WALL
        Surface.blit(tileset, 2*16, 5*16, 16, 16, tile, 0, 16)
      elsif vertical == WALL and side == FLOOR
        Surface.blit(tileset, 0*16, 3*16, 16, 16, tile, 0, 16)
      elsif diagonal == WALL and vertical == WALL and side == WALL
        Surface.blit(tileset, 2*16, 3*16, 16, 16, tile, 0, 16)
      end
      # d
      diagonal = Map.is_wall_or_floor?(id, SOUTHEAST)
      vertical = Map.is_wall_or_floor?(id, SOUTH)
      side = Map.is_wall_or_floor?(id, EAST)
      if diagonal == FLOOR and side == WALL and vertical == WALL
        Surface.blit(tileset, 3*16, 1*16, 16, 16, tile, 16, 16)
      elsif diagonal == FLOOR and side == FLOOR and vertical == FLOOR
        Surface.blit(tileset, 3*16, 5*16, 16, 16, tile, 16, 16)
      elsif diagonal == WALL and vertical == FLOOR and side == FLOOR
        Surface.blit(tileset, 3*16, 5*16, 16, 16, tile, 16, 16)
      elsif vertical == FLOOR and side == WALL
        Surface.blit(tileset, 1*16, 5*16, 16, 16, tile, 16, 16)
      elsif vertical == WALL and side == FLOOR
        Surface.blit(tileset, 3*16, 3*16, 16, 16, tile, 16, 16)
      elsif diagonal == WALL and vertical == WALL and side == WALL
        Surface.blit(tileset, 1*16, 3*16, 16, 16, tile, 16, 16)
      end

      @autotile_wall[id] = tile
    end
  end

  def wall(id)
    @autotile_wall[id]
  end
end
