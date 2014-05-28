# -*- coding: utf-8 -*-
# ワープする
# [表示する時間(f), [基本座標からの増減], [何枚目, 方向]]
MOTION_WARP = [
  [1, [0, -16*1], [0, DOWN]],
  [1, [0, -16*2], [0, DOWN]],
  [1, [0, -16*3], [0, DOWN]],
  [1, [0, -16*4], [0, DOWN]],
  [1, [0, -16*5], [0, DOWN]],
  [1, [0, -16*6], [0, DOWN]],
  [1, [0, -16*7], [0, DOWN]],
  [1, [0, -16*8], [0, DOWN]],
  [1, [0, -16*9], [0, DOWN]],
  [1, [0, -16*10], [0, DOWN]],
  [1, [0, -16*11], [0, DOWN]],
  [1, [0, -16*12], [0, DOWN]],
  [1, [0, -16*13], [0, DOWN]],
  [1, [0, -16*14], [0, DOWN]],
  [1, [0, -16*15], [0, DOWN]],
  [1, [0, -16*16], [0, DOWN]],
]
MOTION_WARP_DOWN = [
  [1, [0, -16*16], [0, DOWN]],
  [1, [0, -16*15], [0, DOWN]],
  [1, [0, -16*14], [0, DOWN]],
  [1, [0, -16*13], [0, DOWN]],
  [1, [0, -16*12], [0, DOWN]],
  [1, [0, -16*11], [0, DOWN]],
  [1, [0, -16*10], [0, DOWN]],
  [1, [0, -16*9], [0, DOWN]],
  [1, [0, -16*8], [0, DOWN]],
  [1, [0, -16*7], [0, DOWN]],
  [1, [0, -16*6], [0, DOWN]],
  [1, [0, -16*5], [0, DOWN]],
  [1, [0, -16*4], [0, DOWN]],
  [1, [0, -16*3], [0, DOWN]],
  [1, [0, -16*2], [0, DOWN]],
  [1, [0, -16*1], [0, DOWN]],
]

# 歩く(足踏み)
def walk_in_place(direction)
  [
    [15, [0, 0], [0, direction]],
    [15, [0, 0], [1, direction]],
    [15, [0, 0], [2, direction]],
    [15, [0, 0], [1, direction]],
  ]
end

MOTION_WALK_IN_PLACE_DOWN = walk_in_place(DOWN)
MOTION_WALK_IN_PLACE_LEFT = walk_in_place(LEFT)
MOTION_WALK_IN_PLACE_RIGHT = walk_in_place(RIGHT)
MOTION_WALK_IN_PLACE_UP = walk_in_place(UP)
MOTION_WALK_IN_PLACE_UPPER_RIGHT = walk_in_place(UPPER_RIGHT)
MOTION_WALK_IN_PLACE_BOTTOM_RIGHT = walk_in_place(BOTTOM_RIGHT)
MOTION_WALK_IN_PLACE_BOTTOM_LEFT = walk_in_place(BOTTOM_LEFT)
MOTION_WALK_IN_PLACE_UPPER_LEFT = walk_in_place(UPPER_LEFT)

# 攻撃する
def attack(direction)
  result = []
  (0..7).each do |n|
    result << [1, direction_to_offsets(direction).map {|x| x*n*3}, [0, direction]]
  end
  (0..7).to_a.reverse.each do |n|
    result << [1, direction_to_offsets(direction).map {|x| x*n*3}, [0, direction]]
  end
  return result
end

MOTION_ATTACK_DOWN = attack(DOWN)
MOTION_ATTACK_LEFT = attack(LEFT)
MOTION_ATTACK_RIGHT = attack(RIGHT)
MOTION_ATTACK_UP = attack(UP)
MOTION_ATTACK_UPPER_RIGHT = attack(UPPER_RIGHT)
MOTION_ATTACK_BOTTOM_RIGHT = attack(BOTTOM_RIGHT)
MOTION_ATTACK_BOTTOM_LEFT = attack(BOTTOM_LEFT)
MOTION_ATTACK_UPPER_LEFT = attack(UPPER_LEFT)

def motion_length(motion)
  total_frame_count = 0
  motion.each do |row|
    total_frame_count += row[0]
  end
  return total_frame_count
end

# 点滅する(死ぬ時)
def get_blink_motion(direction)
  result = []
  (0..15).each do |n|
    if n % 2 == 0
      result << [2, [0,0], [0, direction]]
    else
      result << [2, [1000,1000], [0, direction]] # 画面外
    end
  end
  return result
end

def get_walk_motion( direction )
  walk_anim = [0, 1, 2, 1]
  result = []
  x, y = direction_to_offsets(direction)
  (0..15).each do |n|
    result << [1, [x*n, y*n], [walk_anim [ n % 4 ], direction]] 
  end
  return result
end
