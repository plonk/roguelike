# -*- coding: utf-8 -*-

def bool2num(b)
  if b
    1
  else
    0
  end
end

FLOOR = " ".ord
WALL = ",".ord

NORTHWEST	= 1 << 0
NORTH		= 1 << 1
NORTHEAST	= 1 << 2
WEST		= 1 << 3
EAST		= 1 << 4
SOUTHWEST	= 1 << 5
SOUTH		= 1 << 6
SOUTHEAST	= 1 << 7

# Map: ランダムマップを扱うクラス
# 例:
# 	map = Map.new
# 	coords = map.get_random_place	# [x, y]
# 	map[*coords]			# => "," or " "
class Map
  PHASE2_ROUNDS = 5 # phase2 アルゴリズムを適用する回数
  attr_accessor :data

  # Map.new: WIDTH × HEIGHT のマップを作る
  def initialize(str = nil)
    if str
      @data = str
      if str.length != WIDTH*HEIGHT
        raise "length must be WIDTH(#{WIDTH})*HEIGHT(#{HEIGHT})"
      end
    else
      @data = String(WALL.chr * (WIDTH*HEIGHT)) # 全部壁で初期化
      phase1
      PHASE2_ROUNDS.times { phase2 }
    end
    # オートタイルの番号を表すバイト列
    @atinfo = String.new(0.chr * (WIDTH*HEIGHT))
    @atinfo.force_encoding("ASCII-8BIT")

    calc_atinfo
  end

  def get_by_direction(x, y, dir)
    case dir
    when NORTHWEST
      self[x-1,y-1]
    when NORTH
      self[x,y-1]
    when NORTHEAST
      self[x+1,y-1]
    when WEST
      self[x-1,y]
    when EAST
      self[x+1,y]
    when SOUTHWEST
      self[x-1,y+1]
    when SOUTH
      self[x,y+1]
    when SOUTHEAST
      self[x+1,y+1]
    end
  end

  def atinfo(x, y)
    return 0xff if out_of_bounds?(x, y)
    return @atinfo[y*WIDTH + x].ord
  end

  def calc_atinfo
    (0...HEIGHT).each do |y|
      (0...WIDTH).each do |x|
        if self[x, y] == WALL
          @atinfo.setbyte(y*WIDTH + x, calc_atid(x, y))
        else
          @atinfo.setbyte(y*WIDTH + x, 0x00)
        end
      end
    end
  end

  def calc_atid(x, y)
    number = 0
    shift_amount = 0
    (y-1..y+1).each do |yy|
      (x-1..x+1).each do |xx|
        unless x == xx and y == yy
          number |= bool2num(self[xx, yy] == WALL) << shift_amount
          shift_amount += 1
        end
      end
    end
    return number
  end

  # Map#get(x, y):
  # 	位置 [x, y] の種類を文字列で返す。
  # 	" " は床、"," は壁。
  def get(x, y, dir = nil)
    unless dir
      return WALL if out_of_bounds?(x, y)
      return @data.getbyte(y * WIDTH + x)
    else
      return get_by_direction(x, y, dir)
    end
  end
  alias :[] :get

  # 内部用。縁を壁とはカウントさせない
  def get2(x, y)
    return FLOOR if out_of_bounds?(x, y)
#    return ',' if on_fringe?(x, y)
    return get(x, y)
  end

  def to_s
    return @data.scan(/.{#{WIDTH}}/).join("\n")
  end

  def on_fringe?(x, y)
    return (x == 0 or x == WIDTH-1 or y == 0 or y == HEIGHT-1)
  end

  def out_of_bounds?(x, y)
    return (x < 0 or x >= WIDTH or y < 0 or y >= HEIGHT)
  end

  def []=(x, y, value)
    @data.setbyte(y*WIDTH + x, value)
  end

  def enterable?(x, y)
    if (x == 0 or x == WIDTH-1 or y == 0 or y == HEIGHT-1)
      return false
    elsif get(x, y) == FLOOR
      return true
    else
      return false
    end
  end

  # ランダムな床 [x, y] を返す。
  def get_random_place
    x = [*1...WIDTH-1].sample
    y = [*1...HEIGHT-1].sample
    if get(x, y) == WALL
      return get_random_place
    else
      return x, y
    end
  end

  # ランダムに壁か床にする
  # 40% の確率で壁
  def phase1
    (0...WIDTH).each do |x|
      (0...HEIGHT).each do |y|
        unless on_fringe?(x, y)
          self[x, y] = (0..0.4).include?(rand) ? WALL : FLOOR
        end
      end
    end
  end

  # セルオートマトンさん
  def phase2
    buf = self.dup
    buf.data = self.data.dup
    (0...WIDTH).each do |x|
      next if x == 0 or x == WIDTH-1
      (0...HEIGHT).each do |y|
        next if y == 0 or y == HEIGHT-1

        wc = 0 # wall count
        [[x - 1, y - 1], 
          [x    , y - 1], 
          [x + 1, y - 1], 
          [x - 1, y    ], 
          [x, y ],
          [x + 1, y    ], 
          [x - 1, y + 1], 
          [x    , y + 1], 
          [x + 1, y + 1], ].each do |x2, y2|
          wc += 1 if get2(x2, y2) == WALL
        end

        wc2 = wc # wall count
        [[x - 2, y - 1],
          [x - 2, y    ],
          [x - 2, y + 1],
          [x + 2, y - 1],
          [x + 2, y    ],
          [x + 2, y + 1],
          [x - 1, y - 2],
          [x + 0, y - 2],
          [x + 1, y - 2],
          [x - 1, y + 2],
          [x + 0, y + 2],
          [x + 1, y + 2],].each do |x2, y2|
          wc2 += 1 if get2(x2, y2) == WALL
        end
        

        if wc >= 5 or wc2 <= 2
          buf[x, y] = WALL
        else
          buf[x, y] = FLOOR
        end
      end
    end
    @data = buf.data
  end

  # 数値 ID の「方向」番目のビットが立っていたら WALL を返す
  def Map.is_wall_or_floor?(id, dir)
    if id & dir != 0
      return WALL
    else
      return FLOOR
    end
  end

end


class KobeyaMap < Map
  # Map.new: WIDTH × HEIGHT のマップを作る
  def initialize
    @data = String(WALL.chr * (WIDTH*HEIGHT)) # 全部壁で初期化

    ox =  WIDTH / 2
    oy = HEIGHT / 2

    xbeg = ox - 5
    xend = ox + 5
    ybeg = oy - 5
    yend = oy + 5

    (ybeg..yend).each do |y|
      (xbeg..xend).each do |x|
        self[x, y] = FLOOR
      end
    end

    super(data)
  end
end

# 56 × 34
# 14*4 X 8

class NiheyaMap < Map
  # Map.new: WIDTH × HEIGHT のマップを作る
  def initialize
    @data = String(WALL.chr * (WIDTH*HEIGHT)) # 全部壁で初期化

    [[WIDTH/4, HEIGHT/2], [WIDTH/4*3, HEIGHT/2]].each do |ox, oy|
      xbeg = ox - 10
      xend = ox + 10
      ybeg = oy - 15
      yend = oy + 15

      (ybeg..yend).each do |y|
        (xbeg..xend).each do |x|
          self[x, y] = FLOOR
        end
      end
    end

    middle_x = WIDTH/4 + 10 + 2 + rand(5).to_i
    top = HEIGHT/2 - 15 + 1
    y1 = top + rand(28).to_i
    y2 = nil
    while (y2 = top + rand(28).to_i) == y1
    end
    y1, y2 = [y1, y2].sort # 小さい順にする

#    [middle_x, y1]
#    [middle_x, y2]

    (WIDTH/4..middle_x).each do |x|
      self[x, y1] = FLOOR
    end

    (y1..y2).each do |y|
      self[middle_x, y] = FLOOR
    end

    (middle_x..WIDTH/4*3).each do |x|
      self[x, y2] = FLOOR
    end
    # (WIDTH/4..WIDTH/4*3).each do |x|
    #   self[x, HEIGHT/2] = FLOOR
    # end

    super(data)
  end
end
