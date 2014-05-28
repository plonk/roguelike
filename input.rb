# -*- coding: utf-8 -*-
# HID モジュール
module Input
  @@PREV_KEY = {}
  @@CUR_KEY = {}
  @@JOY2KEY = {
    2=>Key::Z,                  # 攻撃
    1=>Key::A,                  # 取消し
    8=>Key::X,                  # 場所固定
    4=>Key::S,                  # メニュー
    5=>Key::Q,                  # 特技
    7=>Key::W,                  # 斜め
    9=>Key::SPACE,              # マップのみ
    6=>Key::G,                  # ガイドライン
    3=>Key::F                   # iDash
  }
  @@JOYSTICK = nil
  # Z A X S Q W SPACE G F
  # 2 1 8 4 5 7 9     6 3
  AXIS_MAX = 32767
  AXIS_MIN = -32768
  X_AXIS = 0
  Y_AXIS = 1
  @@INITIALIZED_P = false

  # Input.scan
  def Input.scan
    raise "Input.init must be called beforehand"  unless @@INITIALIZED_P
    Key.scan

    now = Time.now

    @@PREV_KEY.replace(@@CUR_KEY)

    # 定義されているキーシンボルのほとんどを
    # 記録する
    SDL::Key.constants.each do |sym|
      keysym = eval("SDL::Key::" + sym.to_s)
      if keysym < 500
        if Key.press?(keysym)
          @@CUR_KEY[keysym] = older_time(@@PREV_KEY[keysym], now)
        else
          @@CUR_KEY[keysym] = nil
        end
      end
    end

    return unless @@JOYSTICK

    # ジョイパッド
    @@JOY2KEY.keys.each do |i|
      key = @@JOY2KEY[i]
      if @@JOYSTICK.button(i-1)
        @@CUR_KEY[key] = older_time(@@PREV_KEY[key], now)
      end
    end

    x = @@JOYSTICK.axis(X_AXIS)
    y = @@JOYSTICK.axis(Y_AXIS)
    @@CUR_KEY[Key::RIGHT] = older_time(@@PREV_KEY[Key::RIGHT], now) if x >= AXIS_MAX/2
    @@CUR_KEY[Key::LEFT] = older_time(@@PREV_KEY[Key::LEFT], now) if x <= AXIS_MIN/2
    @@CUR_KEY[Key::UP] = older_time(@@PREV_KEY[Key::UP], now) if y <= AXIS_MIN/2
    @@CUR_KEY[Key::DOWN] = older_time(@@PREV_KEY[Key::DOWN], now) if y >= AXIS_MAX/2
  end

  def Input.older_time(a, b)
    raise if a == nil and b == nil # can't both be nil.
    return b if a == nil
    return a if b == nil
    if b > a
      return a
    else
      return b
    end
  end

  def Input.init
    @@INITIALIZED_P = true

    if Joystick.num == 0
      puts "No joysticks found"
    else
      puts "#{Joystick.num} joysticks found"
      puts "opening first one"
      @@JOYSTICK = Joystick.open(0)
    end
  end

  # Input.pressed? Key::X
  def Input.pressed?(keysym, min_duration_sec = 0)
    raise "Input.init must be called beforehand"  unless @@INITIALIZED_P

    now = Time.now # scan 時のタイムスタンプのほうが良いような気がする…
    timestamp = @@CUR_KEY[keysym]
    return false unless timestamp 
#    p [now, timestamp, now - timestamp]
    if now - timestamp >= min_duration_sec
      return true 
    else
      return false
    end
  end

  # 前回のスキャンで pressed? == false
  # 現在のスキャンで pressed? == true の場合 true
  def Input.triggered?(keysym)
    raise "Input.init must be called beforehand"  unless @@INITIALIZED_P

    @@PREV_KEY[keysym] == nil and @@CUR_KEY[keysym]
  end
end
