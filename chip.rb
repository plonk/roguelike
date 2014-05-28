# -*- coding: utf-8 -*-

=begin
# キャラクターチップ。32x32 の画像が横に4枚ならんだものが
# 8方向に応じて8列ある 128x256 の画像。
class Chip
  # fname: ファイル名
  # orig_x, orig_y: 画像内で 128x256 の単位を構成する左上の原点
  def initialize(fname, orig_x = 0, orig_y = 0)
    @@image_cache ||= Hash.new
    
    @image = @@image_cache[fname]
    unless @image
      @image = Surface.load(fname)
      @@image_cache[fname] = @image
    end

    @orig_x = orig_x
    @orig_y = orig_y
  end

  def draw(dir, frame, x, y)
    Surface.blit(@image, 
                 @orig_x+frame*32, @orig_y+dir*32,
                 32, 32,
                 $screen,
                 x, y)
  end
end
=end

# キャラクターチップ。32x32 の画像が横に4枚ならんだものが
# 8方向に応じて8列ある 128x256 の画像。
class Chip
  DEFAULT_SCALE = 1

  # fname: ファイル名
  # orig_x, orig_y: 画像内で 128x256 の単位を構成する左上の原点
  def initialize(fname, orig_x = 0, orig_y = 0)
    @@image_cache ||= Hash.new
    
    @image = @@image_cache[fname]
    unless @image
      @image = Surface.load(fname)
      @@image_cache[fname] = @image
    end

    tmp = Surface.new(HWSURFACE, @image.w, @image.h, $screen.format)
    tmp.fill_rect(0, 0, tmp.w, tmp.h, [255,0,255])
    tmp.put(@image, 0, 0)
    @image = tmp
    @image.set_color_key(SRCCOLORKEY, [255,0,255])
    @orig_x = orig_x
    @orig_y = orig_y
    @scale = DEFAULT_SCALE
  end

  attr_accessor :scale

  # x, y: 画像の中央
  def draw(dir, frame, x, y)
    Surface.blit(@image, 
                 @orig_x+frame*32, @orig_y+dir*32,
                 32, 32,
                 $field,
                 x-16, y-16)
  end
end

