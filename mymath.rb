# -*- coding: utf-8 -*-

# 角度をラジアンに変換する
def deg2rad(deg)
  deg * PI / 180
end

# ラジアンを角度に変換する
def rad2deg(rad)
  rad * 180 / PI
end

# 角度と速度のペアをベクトルに変換する
def ae2vec(angle, energy)
  rad_angle = angle * PI / 180
  [cos(rad_angle) * energy, sin(rad_angle) * energy]
end

# ベクトルを角度と速度のペアに変換する
# atan2 で書き直せる気がする
# def vec2ae(vector)
#   x = vector[0]
#   y = vector[1]
#   energy = sqrt(x ** 2 + y ** 2)
#   # y / energy = sin(theta)
#   rad_angle = asin(y/energy) # ???
#   # puts "angle = #{rad_angle} rad, which is #{rad2deg(rad_angle)} degrees"
#   # うまくうごかないので象限ごとに調整します！
#   if x < 0 and y >= 0
#     rad_angle = PI - rad_angle
#   elsif x < 0 and y < 0
#     rad_angle = PI - rad_angle
#   elsif x >= 0 and y < 0
#     rad_angle = 2 * PI + rad_angle
#   end
#   angle = rad2deg(rad_angle)
#   [angle, energy]
# end

def vec2ae(vector)
  x = vector[0]
  y = vector[1]
  energy = sqrt(x ** 2 + y ** 2)
  rad_angle = atan2(y, x)
  angle = rad2deg(rad_angle)
  [angle, energy]
end

# 2つのベクトルを加算する
def addvec(v1, v2)
  v3 = [nil, nil]
  v3[0] = v1[0] + v2[0]
  v3[1] = v1[1] + v2[1]
  v3
end
