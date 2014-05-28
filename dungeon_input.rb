# -*- coding: utf-8 -*-
class DungeonInput
  def map?
    Input.pressed? Key::SPACE
  end

  def first_forward?
    Input.pressed? Key::Z and Input.pressed? Key::A
  end

  def menu?
    Input.triggered? Key::S
  end

  def debug_menu?
    Input.triggered? Key::D
  end

  def attack?
    Input.pressed?(Key::Z, 0.010) # 10msec 以上前から押されていたら
  end

  def rotate?
    Input.pressed? Key::X
  end

  def quit?
    Input.pressed? Key::ESCAPE
  end

  def diagonal_locked?
    # return (Input.pressed? Key::W or Input.pressed? Key::LSHIFT)
    return Input.pressed? Key::W
  end

  # 入力されている場合は方向を
  # 入力がない場合は nil を返す
  def direction
    if Input.pressed? Key::UP and Input.pressed? Key::LEFT
      return UPPER_LEFT
    elsif Input.pressed? Key::UP and Input.pressed? Key::RIGHT
      return UPPER_RIGHT
    elsif Input.pressed? Key::DOWN and Input.pressed? Key::LEFT
      return BOTTOM_LEFT
    elsif Input.pressed? Key::DOWN and Input.pressed? Key::RIGHT
      return BOTTOM_RIGHT
    end

    return nil if diagonal_locked?

    if Input.pressed? Key::UP
      UP
    elsif Input.pressed? Key::DOWN
      DOWN
    elsif Input.pressed? Key::LEFT
      LEFT
    elsif Input.pressed? Key::RIGHT
      RIGHT
    else
      nil
    end
  end
end
