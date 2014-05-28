# -*- coding: utf-8 -*-

class GameObject
  attr_reader :xpos, :ypos
  attr_reader :oldx, :oldy

  def initialize(xpos, ypos)
    @xpos = xpos
    @ypos = ypos
    @oldx = @xpos
    @oldy = @ypos
  end

  # coords: [xpos, ypos]
  def position=(coords)
    @oldx = @xpos
    @oldy = @ypos 
    @xpos, @ypos = coords 
  end

  def position
    return [@xpos, @ypos]
  end

  def on_enter(game)
  end
end

class Character < GameObject
  attr_accessor :direction
  attr_accessor :offense, :hp, :max_hp, :level
  attr_reader :name

  # タイルの中心に立っているように見せるためのオフセット
  YOFFSET = -4
  def initialize(xpos = 0, ypos = 0, fname)
    super(xpos, ypos)
    @direction = DOWN
    @motion_frame_count = 0
    @mstack = []
    @mstack << MOTION_WALK_IN_PLACE_DOWN
    @mindex = 0 # モーション内での再生位置

    # キャラクターの切り出し
    @chip = Chip.new(fname)


    # 状態以上のテーブル、シンボルからターン数へ。
    # その状態でない場合は 0 。
    # @state_table[:yokumie] == 0 # よくみえ状態でなければ
    @state_table = Hash.new(0)
  end

  # sym: 状態名 :yokumie, :suimin, :konran, :zowazowa
  # duration: その状態が持続するターン数
  def set_state(sym, duration)
    @state_table[sym] = duration
  end

  def has_state?(sym)
    @state_table[sym] != 0
  end

  # フロアが変更される時に呼びだされるべき
  def reset_state
    @state_table = Hash.new(0)
  end

  def change_direction(newdir)
    return if @direction == newdir
    @direction = newdir
    case newdir
    when DOWN
      set_motion(MOTION_WALK_IN_PLACE_DOWN)
    when LEFT
      set_motion(MOTION_WALK_IN_PLACE_LEFT)
    when RIGHT
      set_motion(MOTION_WALK_IN_PLACE_RIGHT)
    when UP
      set_motion(MOTION_WALK_IN_PLACE_UP)
    when UPPER_RIGHT
      set_motion(MOTION_WALK_IN_PLACE_UPPER_RIGHT)
    when BOTTOM_RIGHT
      set_motion(MOTION_WALK_IN_PLACE_BOTTOM_RIGHT)
    when BOTTOM_LEFT
      set_motion(MOTION_WALK_IN_PLACE_BOTTOM_LEFT)
    when UPPER_LEFT
      set_motion(MOTION_WALK_IN_PLACE_UPPER_LEFT)
    end
  end

  def set_motion(motion)
    @mstack = [motion]
    @mindex = 0
  end

  def push_motion(motion)
    @mstack.push(motion)
    @mindex = 0
  end

  def in_motion?
    @mstack.size > 1
  end

  def pop_motion
    @mstack.pop
  end

  def draw(x, y)
    dur, coords, frame_and_dir = @mstack.last[@mindex]
    frame, dir = frame_and_dir
    @chip.draw(dir, frame, x + coords[0], y+YOFFSET + coords[1])
    @motion_frame_count += 1
    if @motion_frame_count >= dur
      @motion_frame_count = 0
      @mindex += 1
      if @mstack.last[@mindex] == nil
        # スタック最下部のモーションは pop せず永久ループ
        pop_motion if @mstack.size > 1
        @mindex = 0
      end
    end
  end

  def damage(point, agent)
    @hp -= point
  end

  def dead?
    @hp < 1
  end

  def at_same_place(obj)
    obj.xpos == @xpos and obj.ypos == @ypos
  end

  def adjacent_to?(obj)
    raise unless obj.is_a? GameObject
    false if at_same_place(obj)
    if (@xpos - obj.xpos).abs <= 1 and
        (@ypos - obj.ypos).abs <= 1 then
      true
    else
      false
    end
  end

  def heal(point)
    @hp = @hp + point > @max_hp ? @max_hp : @hp + point
  end
end

$ENEMY_DB = {
  "ちんたら"=>{
    :max_hp => 6,
    :offense => 2,
    :exp => 5,
    :sprite_sheet => "data/Chintara.png",
  },
  "ベネフィット"=>{
    :max_hp => 10,
    :offense => 50,
    :exp => 5000,
    :sprite_sheet => "data/Benefit.png",
  },
  "悪い箱"=>{
    :max_hp => 5,
    :offense => 2,
    :exp => 3,
    :sprite_sheet => "data/Enemy.png",
  }
}

class Enemy < Character
  attr_reader :exp
  def initialize(xpos, ypos, name)
    enemy = $ENEMY_DB[name]
    super(xpos, ypos, enemy[:sprite_sheet])

    @name = name
    @max_hp = enemy[:max_hp]
    @hp = @max_hp
    @level = 1
    @offense = enemy[:offense]
    @exp = enemy[:exp]
  end

  # inflict damage to the character
  def damage(point, agent)
    super
    $scene.puts("#{agent.name}は #{self.name} に\n" + 
                "#{point} のダメージをあたえた")
    if dead?
      m = get_blink_motion(@direction)
      # 攻撃主のモーションが終わってから、点滅を始める
      $scene.queue { push_motion(m); $scene.dungeon_state = :WAIT_MOTION }
    end
  end
end

class Inventory < Array
  def full?
    self.size == 20
  end

  def <<(item)
    raise "Item expected" unless item.is_a? Item
    super
  end
end

$LEVEL_EXP = [nil, 0, 10, 30, 60, 100,
160, 250, 370, 530, 730, 970, 1300,
1600, 2000, 2400, 2900]  # ....

class PlayerCharacter < Character
  attr_reader :exp, :gold
  attr_reader :inventory

  def initialize(xpos = 0, ypos = 0)
    super(xpos, ypos, 'data/Actor2.png')
    @max_hp = 15
    @hp = 15
    @level = 1
    @exp = 0

    @gold = 0
    @name ="予定地"

    @inventory = Inventory.new
  end

  def offense
    @level + 3
  end

  def hp
    @hp.to_i
  end

  def natural_heal
    heal(@max_hp.to_f * 0.005 )
  end

  def gain_exp(point)
    @exp += point
    if @exp >= $LEVEL_EXP[@level+1]
      win = MessageWindow.open
      win.add_page("#{self.name} はレベルが上がった。")
      Sound.play("data/fanfare.wav")
      @level += 1
      num = (3..8).to_a.sample
      @max_hp += num
    end
  end

  def damage(point, agent)
    super
    $scene.queue {
      agent_phrase = ""
      agent_phrase = "#{agent.name} に" if agent.is_a? Character
      $scene.puts("#{self.name}は" + agent_phrase + "\n" +
                  "#{point} のダメージを受けた")
    }
    # what if dead?
  end

  def gain_money(value)
    raise "money value must be an Integer" unless value.is_a? Integer
    @gold += value
  end
end

class Exit < GameObject
  def initialize(xpos, ypos)
    super(xpos, ypos)
    @color = get_color("purple")

    @img = load_png("data/exit.png")
  end

  def draw(x, y)
    #    $screen.fill_rect(x - xoffset, y - yoffset, 32, 32, @color)
    $field.put(@img, x - @img.w/2, y - @img.h/2)
  end

  def on_enter(scene)
    scene.goto_next_floor_dialog
  end
end

class Item < GameObject
  attr_reader :name

  def initialize(xpos, ypos)
    super
  end

  def draw(x, y)
    # $screen.draw_circle(x + 16, y + 16, 10, [64, 64, 64], true, true)
    $field.put(@image, x - 16, y - 16)
  end

  def to_s
    @name
  end

  def on_pick(agent)
    agent.inventory << self
  end
end

class OtogiriSou < Item
  def initialize(xpos, ypos)
    super
    @image = load_png("data/herb.png")
    @name = "弟切草"
  end

  def use(pc)
    if pc.max_hp - pc.hp < 1
      pc.max_hp += 4
      pc.hp = pc.max_hp
      $scene.puts("#{pc.name} の最大 HP が 4 上昇した")
    else
      hp = pc.hp + 100
      if hp > pc.max_hp
        hp = pc.max_hp
      end
      pc.hp = hp
      $scene.puts("#{pc.name} の HP が 100 回復した")
    end
  end
end

class Yakusou < Item
  def initialize(xpos, ypos)
    super
    @image = load_png("data/herb.png")
    @name = "薬草"
  end

  def use(pc)
    if pc.max_hp - pc.hp < 1
      pc.max_hp += 4
      pc.hp = pc.max_hp
      $scene.puts("#{pc.name} の最大 HP が 2 上昇した")
    else
      hp = pc.hp + 100
      if hp > pc.max_hp
        hp = pc.max_hp
      end
      pc.hp = hp
      $scene.puts("#{pc.name} の HP が 25 回復した")
    end
  end
end

class MegusuriSou < Item
  def initialize(xpos, ypos)
    super
    @image = load_png("data/herb.png")
    @name = "めぐすり草"
  end

  def use(pc)
    $scene.puts("ワナが見えるようになった")
    Sound.play("data/kiri.wav")
    pc.set_state(:yokumie, 1500)
    Effects.start_ring(320, 240)
#    $scene.queue {  }
  end
end

class TakatobiSou < Item
  def initialize(xpos, ypos)
    super
    @image = load_png("data/herb.png")
    @name = "高とび草"
  end

  def use(pc)
    $scene.puts("#{pc.name} は高とんだ")
    $scene.queue { $scene.warp }
  end
end


# アイテム扱いしたほうがいいかな
class MoneyBag < Item
  attr_reader :value

  def initialize(xpos, ypos)
    super
    @image = load_png("data/moneybag.png")
    @value = 300 + rand(700)
  end

  def draw(x, y)
    $field.put(@image, x - 16, y - 16)
  end

  def name
    "#{@value}ギタン"
  end

  def to_s
    name
  end

  def on_pick(agent)
    agent.gain_money(@value)
  end
end


require_relative 'traps'
