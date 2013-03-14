# -*- coding: utf-8 -*-
# 40%の確率で壁、60%の確率で通路を作るコード

class String
  def get(x, y)
    if x <= 0 or x >= WIDTH-1 or y <= 0 or y >= HEIGHT-1
      if (x == 0 or x == WIDTH-1 or y == 0 or y == HEIGHT-1) and 
          (x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT)
        # 画面端の軸上、かつ画面外ではない
#    return self[y * WIDTH + x]
        return ' '
      else
        return ' '
      end
    end
    return self[y * WIDTH + x]
  end
end

def phase1(buf)
  (0...WIDTH).each do |x|
    (0...HEIGHT).each do |y|
      unless x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        buf[y*WIDTH+x] = (0..0.4).include?(rand) ? "," : " "
      end
    end
  end
  return buf
end

def phase2(buf)
  old = buf
  buf = buf.dup 
  (0...WIDTH).each do |x|
    next if x == 0 or x == WIDTH-1
    (0...HEIGHT).each do |y|
      next if y == 0 or y == HEIGHT-1

      wc = 0 # wall count
      wc += 1 if old.get(x - 1, y - 1) == ","
      wc += 1 if old.get(x    , y - 1) == ","
      wc += 1 if old.get(x + 1, y - 1) == ","
      wc += 1 if old.get(x - 1, y    ) == ","
#      wc += 1 if old.get(x    , y    ) == "," # 自分自身も数えるの？
      wc += 1 if old.get(x + 1, y    ) == ","
      wc += 1 if old.get(x - 1, y + 1) == ","
      wc += 1 if old.get(x    , y + 1) == ","
      wc += 1 if old.get(x + 1, y + 1) == ","

      wc2 = wc # wall count
      wc2 += 1 if old.get(x - 2, y - 1) == ","
      wc2 += 1 if old.get(x - 2, y    ) == ","
      wc2 += 1 if old.get(x - 2, y + 1) == ","
      wc2 += 1 if old.get(x + 2, y - 1) == ","
      wc2 += 1 if old.get(x + 2, y    ) == ","
      wc2 += 1 if old.get(x + 2, y + 1) == ","
      wc2 += 1 if old.get(x - 1, y - 2) == ","
      wc2 += 1 if old.get(x + 0, y - 2) == ","
      wc2 += 1 if old.get(x + 1, y - 2) == ","
      wc2 += 1 if old.get(x - 1, y + 2) == ","
      wc2 += 1 if old.get(x + 0, y + 2) == ","
      wc2 += 1 if old.get(x + 1, y + 2) == ","

      if wc >= 5 or wc2 <= 2
        buf[y*WIDTH+x] = ","
      else
        buf[y*WIDTH+x] = " "
      end
    end
  end
  old.replace(buf)
end

def print_buffer(buf)
  (0...HEIGHT).each do |y|
    (0...WIDTH).each do |x|
      if x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        @screen.fill_rect(x * 32, y * 32, 32, 32, [128, 64, 64])
        next
      end

      tile = nil
      if buf.get(x, y) == ","
        # ab
        # cd

        # a
        diagonal = buf.get(x - 1, y - 1)
        vertical = buf.get(x, y - 1)
        side = buf.get(x - 1, y)
        if diagonal == " " and side == "," and vertical == ","
          Surface.blit(@tileset, 2*16, 0*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == " " and side == " " and vertical == " "
          Surface.blit(@tileset, 0*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == "," and vertical == " " and side == " "
          Surface.blit(@tileset, 0*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif vertical == " " and side == ","
          Surface.blit(@tileset, 2*16, 2*16, 16, 16, @screen, x * 32, y * 32)
        elsif vertical == "," and side == " "
          Surface.blit(@tileset, 0*16, 4*16, 16, 16, @screen, x * 32, y * 32)
        elsif diagonal == "," and vertical == "," and side == ","
          Surface.blit(@tileset, 2*16, 4*16, 16, 16, @screen, x * 32, y * 32)
        end
        # b
        diagonal = buf.get(x + 1, y - 1)
        vertical = buf.get(x, y - 1)
        side = buf.get(x + 1, y)
        if diagonal == " " and side == "," and vertical == ","
          Surface.blit(@tileset, 3*16, 0*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == " " and side == " " and vertical == " "
          Surface.blit(@tileset, 3*16, 2*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == "," and vertical == " " and side == " "
          Surface.blit(@tileset, 3*16, 2*16, 16, 16, @screen, x * 32+ 16, y * 32)
        elsif vertical == " " and side == ","
          Surface.blit(@tileset, 1*16, 2*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif vertical == "," and side == " "
          Surface.blit(@tileset, 3*16, 4*16, 16, 16, @screen, x * 32 + 16, y * 32)
        elsif diagonal == "," and vertical == "," and side == ","
          Surface.blit(@tileset, 1*16, 4*16, 16, 16, @screen, x * 32 + 16, y * 32)
        end
        # c
        diagonal = buf.get(x - 1, y + 1)
        vertical = buf.get(x, y + 1)
        side = buf.get(x - 1, y)
        if diagonal == " " and side == "," and vertical == ","
          Surface.blit(@tileset, 2*16, 1*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif diagonal == " " and side == " " and vertical == " "
          Surface.blit(@tileset, 0*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif diagonal == "," and vertical == " " and side == " "
          Surface.blit(@tileset, 0*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif vertical == " " and side == ","
          Surface.blit(@tileset, 2*16, 5*16, 16, 16, @screen, x * 32, y * 32 + 16)
        elsif vertical == "," and side == " "
          Surface.blit(@tileset, 0*16, 3*16, 16, 16, @screen, x * 32, y * 32+ 16)
        elsif diagonal == "," and vertical == "," and side == ","
          Surface.blit(@tileset, 2*16, 3*16, 16, 16, @screen, x * 32, y * 32+16)
        end
        # d
        diagonal = buf.get(x + 1, y + 1)
        vertical = buf.get(x, y + 1)
        side = buf.get(x + 1, y)
        if diagonal == " " and side == "," and vertical == ","
          Surface.blit(@tileset, 3*16, 1*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif diagonal == " " and side == " " and vertical == " "
          Surface.blit(@tileset, 3*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif diagonal == "," and vertical == " " and side == " "
          Surface.blit(@tileset, 3*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif vertical == " " and side == ","
          Surface.blit(@tileset, 1*16, 5*16, 16, 16, @screen, x * 32 + 16, y * 32 + 16)
        elsif vertical == "," and side == " "
          Surface.blit(@tileset, 3*16, 3*16, 16, 16, @screen, x * 32 + 16, y * 32+ 16)
        elsif diagonal == "," and vertical == "," and side == ","
          Surface.blit(@tileset, 1*16, 3*16, 16, 16, @screen, x * 32 + 16, y * 32+16)
        end

      else
        Surface.blit(@img2, 0, 0, 32, 32, @screen, x * 32, y * 32)
      end

    end # of each
  end # of each
end

def print_buffer_rect(buf)
  (0...HEIGHT).each do |y|
    (0...WIDTH).each do |x|
      if x == 0 or x == WIDTH-1 or
          y == 0 or y == HEIGHT-1
        @screen.fill_rect(x * 32, y * 32, 32, 32, [128, 64, 64])
        next
      end

      tile = buf.get(x, y)
      if tile == ","
        @screen.fill_rect(x * 32, y * 32, 32, 32, [64,64,64])
      elsif tile == " "
        @screen.fill_rect(x * 32, y * 32, 32, 32, [192,192,192])
      else
        raise
      end
    end
  end

end
