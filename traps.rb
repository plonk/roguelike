# -*- coding: utf-8 -*-

class Trap < GameObject
  attr_reader :name
  def initialize(xpos, ypos)
    super
  end

  def draw(x, y)
    # よく見え状態があるのでこうはしない
    # if @visible 
    $field.put(@img, x - @img.w/2, y - @img.h/2)
  end

  def visible=(bool)
    raise "変な値がセットされました" unless bool == true or bool == false
    @visible = bool
  end

  def visible?
    @visible
  end

  def on_enter(scene)
    @visible = true
    activation_prob = @visible ? 0.25 : 0.75
    if rand < activation_prob
      activate
    else
      failure
    end
  end
end

class Hole < Trap
  def initialize(xpos, ypos)
    super
    @img = Surface.load("data/hole.png")
    @visible = false
    @name = "落とし穴"
  end

  def activate
    scene = $scene
    scene.puts("落とし穴だ！")
    scene.queue { scene.fade_out }
    scene.queue { scene.wait_message_response }
    scene.queue { scene.next_floor }
  end

  def failure
    scene = $scene
    scene.puts("落とし穴だ！\nしかし 落ちなかった")
  end
end

class Mine < Trap
  def initialize(xpos, ypos)
    super
    @img = Surface.load("data/mine.png")
    @visible = false
    @name = "地雷"
  end

  def activate
    $scene.queue { $scene.puts("地雷をふんでしまった"); $scene.set_state(:WAIT_MOTION) }
    Effects.start_explosion(320, 240)
    Sound.play("data/mine_explosion.wav")
    pc = $scene.pc
    $scene.queue {
      if pc.hp == 1
        pc.damage(1, self) # 殺す
      else
        n = pc.hp / 2
        pc.damage(n, self)
      end
    }
  end

  def failure
    $scene.puts("地雷をふんでしまった\nしかし作動しなかった")
  end
end

class Warp < Trap
  def initialize(xpos, ypos)
    super
    @img = Surface.load("data/bane.png")
    @visible = false
    @name = "バネ"
  end

  def activate
    $scene.puts("バネだ！")
    $scene.queue { $scene.warp }
  end

  def failure
    $scene.puts("バネだ！\nしかし発動しなかった")
  end
end
