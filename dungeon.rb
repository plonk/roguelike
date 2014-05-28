# -*- coding: utf-8 -*-

require_relative 'effects'

require_relative 'message_window'
require_relative 'input'
require_relative 'status_overlay'
require_relative 'map_view'
require_relative 'dungeon_background'
require_relative 'dungeon_input'

=begin
以下のコードは
次の部分に分割できる
背景、オーバーレイ、
=end
class DungeonScene < Scene
  attr_reader :pc, :floor_level
  attr_accessor :dungeon_state

  def initialize
    super
    $scene = self
    $field = Surface.new(HWSURFACE, 640, 480, $screen.format)
    $miniscreen = Surface.new(HWSURFACE, 320, 240, $screen.format)

    # @dimmer: 視界外を暗くするための黒幕
    @dimmer = Surface.new( HWSURFACE, SCREEN_WIDTH, SCREEN_HEIGHT, $screen.format )
    @dimmer.fill_rect( 0, 0, 640, 480, [0,0,0] ) # まっくろに塗りつぶす
    @dimmer.set_alpha( SRCALPHA, 128 ) # 半透明

    @background = DungeonBackground.new

    @menu_stack = []

    Effects.init($field)

    @offscreen_color = get_color("darkslategray")
    @objects = []
    @queue = []

    load_resources

    $cx = 320 - 16
    $cy = 240 - 16

    @floor_level = 1
    @pc = PlayerCharacter.new
    init_floor

    @inventory_window = InventoryWindow.new(@pc.inventory)

    @status_overlay = StatusOverlay.new(self)
    @map_view = MapView.new

    @map_view.render(@map)
    update_status_overlay

    @message_window = MessageWindow.open

    @input = DungeonInput.new

    @dungeon_state = :TOP_LEVEL
  end

  def load_resources
    # 音
    @wave = Mixer::Wave.load("data/noise.wav")
    @swish_wav = Mixer::Wave.load("data/swish.wav")
    @dungeon_music = Mixer::Music.load("data/tw023.mp3")

    @diagonal_arrows = Surface.load("data/diagarrows.png")
  end

  def event_handler(event)
    return true if super
    return false unless event.is_a? Event::KeyDown # not interested
    case event.sym
    when Key::EQUALS
      Settings.worldview_zoom = !Settings.worldview_zoom
    when Key::L
      load_dungeon_file
      puts "dungeon load"
    when Key::I          # 座標情報のINSPECT
      msg = ["@pc.xpos", "@pc.ypos", "$cx", "$cy"].map {|var| "#{var}: #{eval(var).inspect}"}.join(", ")
      @osd.set_text(msg)
    when Key::Y
      if @pc.has_state?(:yokumie)
        @pc.set_state(:yokumie, 0)
      else
        @pc.set_state(:yokumie, 1500)
      end
      Sound.play("data/kiri.wav")
      puts("よくみえ状態を切り替えました")
      @message_window.clear
    when Key::R          # マップを再構成
      @map.phase2
      @map.calc_atinfo
      @osd.set_text("マップを再構成しました")
      @map_view.render(@map)
    when Key::E          # ワープ
      @pc.push_motion(MOTION_WARP)
      @dungeon_state = :WAIT_MOTION
      queue do
        @pc.position = @map.get_random_place
        @pc.push_motion(MOTION_WARP_DOWN)
        @dungeon_state = :WAIT_MOTION
        queue do
          @message_window.add_page("0 ターンで高とんだよ")
        end
      end
    when Key::O          # マップオーバーレイの切り替え
      Settings.overlay_enabled = !Settings.overlay_enabled
    end
    return true
  end

  def warp
    @pc.push_motion(MOTION_WARP)
    @dungeon_state = :WAIT_MOTION
    queue do
      @pc.position = @map.get_random_place
      @pc.push_motion(MOTION_WARP_DOWN)
      @dungeon_state = :WAIT_MOTION
    end
  end

  def set_osd
    time_msec = "%2d" % ($time_elapsed_in_frame * 1000)
    @osd.set_text("ターン: #{@turn_count}; フレーム: #{$frame_count}; 時間: #{time_msec}msec; 座標: #{@pc.xpos},#{@pc.ypos}; 状態: #{@dungeon_state.to_s}")
  end

  def draw
    set_osd

    case @dungeon_state
    when :NEXT_FLOOR_DIALOG
      next_floor_dialog
    when :WAIT_MOTION
      if @pc.in_motion? or
          @objects.select{|obj| obj.is_a? Character and obj.in_motion?}.any? or
          Effects.busy?
        draw_basics
        draw_overlay
        wait_list = ( [@pc] + @objects.select{|obj|obj.is_a? Character} ).select{|obj|obj.in_motion?}
        @osd.set_text("Waiting for #{wait_list.inspect}")
      else
        @dungeon_state = :TOP_LEVEL
      end
    when :TURN_END
      turn_end
    when :TOP_LEVEL
      if @queue.any?
        @queue[0].call
        @queue.shift
        return draw # @dungeon_state が変更される場合があるので再突入
      end
      dungeon_top_level
    when :DEBUG_MENU
      _debug_menu
    when :MONSTERS_MOVE
      monsters_move2
    when :WAIT_IN_PLACE
      wait_in_place
    when :COMMAND_MENU
      dungeon_command_menu
    when :WAIT_MESSAGE_RESPONSE
      if not @message_window.scrolling? and Input.triggered? Key::Z  # メッセージ送りのできるキーを Array にするべきだな
        @message_window.auto_hide = true
        @dungeon_state = :TOP_LEVEL
      end
      draw_basics
      # draw_dimmer
      draw_overlay
    when :DO_NOTHING
    end

    super

    @next_scene
  end

  def create_command_menu
    menu = Menu.new
    menu.set_size(32*4 + 10, 4*32 + Menu::TOP_MARGIN*2)
    menu.add_item("道具") do
      @inventory_window.reset
      @dungeon_state = :COMMAND_MENU
    end
    menu.add_item("足元") do
      things_on_floor = @objects.select { |obj| obj.is_a? Item or obj.is_a? Trap or obj.is_a? Exit }
      under_feet = things_on_floor.select { |obj|
        obj.xpos == @pc.xpos and obj.ypos == @pc.ypos }
      asimoto_menu = Menu.new
      asimoto_menu.set_position(Menu::X + 50, Menu::Y + 50)
      if under_feet.empty?
        asimoto_menu.add_item("足元には何も落ちていない") do
          # 選択してもなにもしない
        end
      else
        thing = under_feet[0]
        asimoto_menu.add_item(thing.name) do
          # 新たなメニューをひらくわけですよ
          fumu_menu = Menu.new
          fumu_menu.set_position(450, Menu::Y)
          @menu_stack << fumu_menu
          fumu_menu.add_item("ふむ") do
            thing.activate
            @menu_stack.clear
            @dungeon_state = :MONSTERS_MOVE
          end
        end
      end
      @menu_stack << asimoto_menu
    end
    menu.add_item("マップ") do
      Settings.overlay_enabled = !Settings.overlay_enabled
      menu.hide
    end
    menu.add_item("その他") do
      puts "え？聞こえない"
    end
    return menu
  end

  def create_debug_menu
    debug_menu = Menu.new
    Settings.variables.each do |sym|
      label = Settings.label_for(sym)
      assert(label.is_a? String)

      debug_menu.add_item(label) do
        bool_menu = Menu.new
        bool_menu.add_item("ON") do
          @message_window.add_page("#{label}がオンになったよ")
          eval("Settings.#{sym} = true")
          Settings.save
          bool_menu.hide
        end
        bool_menu.add_item("OFF") do
          @message_window.add_page("#{label}がオフになったよ")
          eval("Settings.#{sym} = false")
          Settings.save
          bool_menu.hide
        end
        bool_menu.set_position(450, Menu::Y)
        bool_menu.set_size(110, 74)
        bool_menu.select( Settings.value_for(sym) ? 0 : 1 )
        @menu_stack << bool_menu
      end
    end
    return debug_menu
  end

  def _debug_menu
    input_processed = false
    @menu_stack.reverse_each do |menu|
      if !input_processed and menu.visible?
        menu.update
        break
      end
    end
    @menu_stack.delete_if { |m| not m.visible? }
    if @menu_stack.empty?
      @dungeon_state = :TOP_LEVEL
    end

    draw_basics
    draw_overlay

    @menu_stack.each do |menu|
      menu.draw
    end
  end

  def turn_end
    @pc.natural_heal
    @turn_count += 1
    update_status_overlay
    @message_window.clear
    @dungeon_state = :TOP_LEVEL

    draw_basics
    draw_overlay
  end

  def monsters_move2
    monsters_move
    @pc.position = @pc.position
    walk
    monsters_act
    @dungeon_state = :TURN_END

    draw_basics
    draw_overlay
  end

  def wait_message_response
    @message_window.auto_hide = false
    @dungeon_state = :WAIT_MESSAGE_RESPONSE
  end

  def queue(&block)
    @queue << block
  end

  def goto_next_floor_dialog
    @menu = Window.new(50, 50)
    @black_surface.set_alpha(SRCALPHA, 128)
    @menu.set_text("降りる")
    @dungeon_state = :NEXT_FLOOR_DIALOG
  end

  def next_floor_dialog
    if Input.triggered? Key::A
      @menu = nil
      @dungeon_state = :TOP_LEVEL
    elsif Input.triggered? Key::Z
      @menu = nil
      Sound.play("data/kaidan.wav")
      next_floor
      @dungeon_state = :TOP_LEVEL
    end
    draw_basics
    draw_dimmer
    @menu.draw if @menu
  end

  def dungeon_command_menu
    if Input.pressed? Key::ESCAPE or Input.pressed? Key::A
      # メニューがキャンセルされた
      Sound.beep
      @dungeon_state = :DEBUG_MENU
    end
    draw_basics

    @black_surface.set_alpha(SRCALPHA, 128)
    $field.put(@black_surface, 0, 0)

    @inventory_window.draw
    if @inventory_window.selected?
      item = @inventory_window.selection
      @pc.inventory.delete(@inventory_window.selection)
      item.use(@pc)
      @menu_stack.clear
      @dungeon_state = :MONSTERS_MOVE
    end
  end

  # 次のフロアに進む
  def next_floor
    @message_window.hide
    fade_out
    init_floor
    @map_view.render(@map)
    win = Window.new(SCREEN_WIDTH / 2 - 30, SCREEN_HEIGHT / 2 - 14/2)
    win.set_text("次の階...")
    main_loop (0.5*FPS) do
      fill_screen [0,0,0]
      win.draw
    end
    @floor_level += 1
    update_status_overlay
#    fade_in
  end

  def load_dungeon_file
    floor_sec = []
    map_sec = []
    object_sec = []
    current_section = nil
    # ファイルを読み込む
    File.open("data/debug_dungeon.txt") do |f|
      f.each_line do |line|
        line.chomp!
        case line
        when /^#/
          # コメント行なので無視する
        when "FLOOR"
          current_section = "FLOOR"
        when "MAP"
          current_section = "MAP"
        when "OBJECT"
          current_section = "OBJECT"
        else
          case current_section
          when "FLOOR"
            floor_sec << line
          when "MAP"
            map_sec << line
          when "OBJECT"
            object_sec << line
          end
        end
      end
    end

    # マップが WIDTH * HEIGHT になるようにする
    map_sec.map do |line|
      assert(line =~ /^[, ]+$/)
      assert(line.size <= WIDTH)
      # 足りない桁は壁にする
      if line.size < WIDTH
        line.concat( WALL.chr * (WIDTH - line.size) )
      end
    end
    if map_sec.size < HEIGHT
      map_sec += [WALL.chr * WIDTH] * (HEIGHT - map_sec.size)
    end

    @objects.clear # 罠、階段、モンスターを消去
    # オブジェクト
    object_sec.each do |line|
      klass, rest = line.split(/\s+/, 2)
      args = rest.split(/,\s*/)
      case klass
      when "Monster"
        assert args.size == 3
        print "spawing #{args[0]} at #{args[1]},#{args[2]}\n"
        @objects << Enemy.new(args[1].to_i, args[2].to_i, args[0])
      when "Trap"
        assert args.size == 3
        trap_class = args[0]
        eval("@objects << #{trap_class}.new( args[1].to_i, args[2].to_i )")
      when "Exit"
        assert args.size == 2
        @objects << Exit.new( args[0].to_i, args[1].to_i )
      when "Player"
        assert args.size == 2
        @pc = PlayerCharacter.new( args[0].to_i, args[1].to_i )
        @inventory_window = InventoryWindow.new( @pc.inventory )
      end
    end

    # 実際にロードする
    @map = Map.new( map_sec.join("") )
    @background.update(@map)

    @turn_count = 1
    @floor_level = 1

    @map_view.render(@map)
    update_status_overlay
  end

  def current_visible_rect
    Rectangle.new(@pc.xpos * 32 - $cx,
                  @pc.ypos * 32 - $cy,
                  SCREEN_WIDTH,
                  SCREEN_HEIGHT)
  end

=begin
+------+----------+------+
|      |          |      |
|      +----------+      |
|      |F.ofVISION|      |
|      +----------+      |
|      |          |      |
+------+----------+------+
=end

  def dim_rect(x, y, w, h)
    $field.set_clip_rect( x, y, w, h ) # ひだり
    $field.put( @dimmer, 0,0 )
  end

  def dim(x, y, w, h)
    dim_rect(0, 0, x, 480) # ひだり
    dim_rect(x, 0, w, y)
    dim_rect(x, y+h, w, 480)
    dim_rect(x+w, 0, 640, 480)

    $field.set_clip_rect( 0, 0, 640, 480 ) # disable clip rect
  end

  def draw_basics
    $field.fill_rect(0,0,640,480, @offscreen_color)
    $miniscreen.fill_rect(0,0,320,240, @offscreen_color)
    fill_screen(@offscreen_color)
    draw_background

    $field.set_clip_rect( 320-48, 240-48, 96, 96 )

    range_x = (@pc.xpos - (10 + 1))..(@pc.xpos + (10 + 1))
    range_y = (@pc.ypos - (7 + 1))..(@pc.ypos + (7 + 1))

    # アニメーションが更新されなくなるので
    possibly_visible_objects = @objects

    under = possibly_visible_objects.select do |obj|
      obj.is_a? Item or
      obj.is_a? Exit or
      obj.is_a? Trap
    end
    upper = (possibly_visible_objects - under + [@pc]).sort do |a,b|
      a.ypos <=> b.ypos
    end

    under.each do |obj|
      if obj.is_a? Trap and (not @pc.has_state?(:yokumie) and not obj.visible?)
        # 不可視の罠は描画しない
        next
      end
      obj.draw($cx + (obj.xpos-@pc.xpos) * 32 + 16,
               $cy + (obj.ypos-@pc.ypos) * 32 + 16)
    end
    upper.each do |obj|
      obj.draw($cx + (obj.xpos-@pc.xpos) * 32 + 16,
               $cy + (obj.ypos-@pc.ypos) * 32 + 16)
    end

    $field.set_clip_rect(0, 0, 640, 480) # disable clip rect
    dim(320-48, 240-48, 96, 96)

    draw_diagonal_arrows

    Effects.draw

    copy_field_to_screen

    @message_window.draw
  end

  def copy_field_to_screen
    if Settings.worldview_zoom
      # 引き伸ばし
      Surface.blit($field, 160, 120, 320, 240,
                   $miniscreen, 0, 0)
      Surface.transform_blit($miniscreen, $screen,
                             0,
                             2.0, 2.0, # scale
                             0, 0,
                             0, 0,
                             0x00)
    else
      Surface.blit($field, 0, 0, 640, 480,
                   $screen, 0, 0)
    end
  end

  def play_noise
    Mixer.play_channel(0, @wave, 0)
  end

  def update_status_overlay
    @status_overlay.update
  end

  # one iteration of 足踏み
  def wait_in_place
    enemy_on_screen_p = @objects.select do |obj|
      obj.is_a? Character and # 本来起きているかの判定が必要
      (-10..10).include?(obj.xpos - @pc.xpos) and
      (-7..7).include?(obj.ypos - @pc.ypos)
    end.any?

    monsters_move
    @pc.position = @pc.position # 移動描画にならないように過去の位置を消す
    if enemy_on_screen_p
      walk
    end
    monsters_act
    @pc.natural_heal
    @turn_count += 1
    update_status_overlay
    @message_window.clear

    unless Input.pressed? Key::Z and Input.pressed? Key::A
      # もはや同時押しされていない
      @dungeon_state = :TOP_LEVEL
    end

    draw_basics
    draw_overlay
  end

  def dungeon_top_level
    if @input.map?
      # マップのみの表示
      fill_screen [0, 0, 0]
      draw_overlay(false)
      return # 通常の描画をせずに戻る
    elsif @input.first_forward?
      # 足踏みモードに移行する
      @dungeon_state = :WAIT_IN_PLACE
    elsif @input.menu?
      @menu_stack << create_command_menu
      Sound.beep
      @dungeon_state = :DEBUG_MENU
    elsif @input.debug_menu?
      @menu_stack << create_debug_menu
      Sound.beep
      @dungeon_state = :DEBUG_MENU
    elsif @input.attack?
      # 攻撃
      Mixer.play_channel(0, @swish_wav, 0)
      attack_motion = attack(@pc.direction)
      @pc.push_motion(attack_motion)
      off = direction_to_offsets(@pc.direction)
      targetx = @pc.xpos + off[0]
      targety = @pc.ypos + off[1]
      enemy = nil
      if someone_there?(targetx, targety )
        enemy = @objects.select{|obj| obj.is_a? Character and
          obj.xpos == targetx and
          obj.ypos == targety}[0]
        point = @pc.offense
        enemy.damage(point, @pc)
      end
      main_loop(motion_length(attack_motion)) do
        draw_basics
        draw_overlay
        @osd.draw
      end
      unless enemy
        # ワナチェック
        trap = @objects.select{|obj| obj.is_a? Trap and
          obj.xpos == targetx and obj.ypos == targety }[0]
        if trap and trap.visible? == false
          # 不可視の場合は 煙を出して可視にする
          xoff = (trap.xpos - @pc.xpos) * 32
          yoff = (trap.ypos - @pc.ypos) * 32
          Effects.start_smoke(320 + xoff, 240 + yoff)
          trap.visible = true
        end
      end
      if enemy and enemy.dead?
        @message_window.add_page("#{enemy.name} をやっつけた！\n"+
                                 "#{enemy.exp} ポイントの経験値を得た")
        @pc.gain_exp(enemy.exp)

        # モーションが終った後で削除する
        # (dead? なやつは TOP_LEVEL の頭で
        # 自動的に削除するようにしたらいいかも)
        queue { @objects.delete(enemy) }
      end
      queue { @dungeon_state = :MONSTERS_MOVE } # モンスター移動フェーズへ移行
    elsif @input.rotate?
      # 方向転換
      if dir = get_direction
        @pc.change_direction(dir)
      end
    elsif @input.quit?
      # タイトルシーンに戻る
      load "./dungeon.rb"
      @next_scene = TitleScene
    elsif dir = @input.direction
      # 十字キーが押されていた
      xpos = @pc.xpos; ypos = @pc.ypos
      xoffset, yoffset = direction_to_offsets(dir)
      xpos += xoffset
      ypos += yoffset
      @pc.change_direction(dir)
      if @map.enterable?(xpos, ypos) and !someone_there?(xpos, ypos)
        # 実際に移動する
        @pc.position = [xpos, ypos]
        monsters_move
        walk unless Input.pressed? Key::A # ダッシュ中
        # walk_by_motion unless Input.pressed? Key::A # ダッシュ中
        queue do
          pick_item
          trap_enter
          monsters_act
          @dungeon_state = :TURN_END
        end
      else
        # なにもしない
      end
    end
    # 特にコマンドが入力されなかった場合も
    # デフォルトのものを描画する
    draw_basics
    draw_overlay
  end

  def draw_diagonal_arrows
    $field.put(@diagonal_arrows, 320 - 32, 240 - 32 - 4) if @input.diagonal_locked?
  end

  def someone_there?(xpos, ypos)
    @objects.each do |obj|
      next unless obj.is_a? Character
      return true if obj.xpos == xpos and obj.ypos == ypos
    end
    false
  end

  def draw_overlay(translucent = true)
    @status_overlay.draw
    return if translucent and !Settings.overlay_enabled

    @map_view.draw(translucent, @pc, @objects)
  end

  def monsters_move
    @monsters = @objects.select {|obj| obj.is_a? Enemy}
    @moved = []
    # 移動
    @monsters.each do |enemy|
      # 攻撃をする。移動しない
      next if enemy.adjacent_to? @pc

      coords = nil
      xoff = @pc.xpos - enemy.xpos
      yoff = @pc.ypos - enemy.ypos
      x = enemy.xpos + 1 if xoff > 0
      x = enemy.xpos - 1 if xoff < 0
      x = enemy.xpos if xoff == 0
      y = enemy.ypos + 1 if yoff > 0
      y = enemy.ypos - 1 if yoff < 0
      y = enemy.ypos  if yoff == 0
      if @map.enterable?(x, y) and not someone_there?(x, y)
        coords = [x, y]
      end

      # Player に向かえないのでランダム移動
      unless coords
        # 隣接する移動可能なマスに移動する
        candidates = [] # 移動先の候補
        (enemy.xpos-1..enemy.xpos+1).each do |x|
          (enemy.ypos-1..enemy.ypos+1).each do |y|
            next if enemy.xpos == x and enemy.ypos == y
            if @map.enterable?(x, y) and not someone_there?(x, y)
              candidates << [x, y]
            end
          end
        end

        next if candidates.empty? # 移動できる場所がない
        coords = candidates.sample
      end

      xpos, ypos = coords
      direction = offsets_to_direction [xpos-enemy.xpos, ypos-enemy.ypos]
      enemy.position = coords
      enemy.change_direction(direction)
      if enemy.adjacent_to? @pc
        # Player に隣接する位置に移動したらプレーヤーの方を向く
        off = [@pc.xpos - enemy.xpos, @pc.ypos - enemy.ypos]
        dir = offsets_to_direction(off)
        enemy.change_direction(dir)
      end
      @moved << enemy
    end
    @moved.each do |enemy|
      @monsters.delete(enemy)
    end
  end

  def monsters_act
    @monsters.each do |enemy|
      point = enemy.offense
      # @message_window.add_page("#{enemy.name}から\n"+
      #                           "#{point} ポイントのダメージを受けた")

      Mixer.play_channel(0, @swish_wav, 0)

      # the two must be adjacent to each other.
      off = [@pc.xpos - enemy.xpos, @pc.ypos - enemy.ypos]
      dir = offsets_to_direction(off)
      enemy.change_direction(dir)
      motion = attack(dir)
      enemy.push_motion(motion)
      main_loop(motion_length(motion)) do
        draw_basics
        draw_overlay
      end

      @pc.damage(point, enemy)

      if @pc.dead?
        game_over
        break
      end
      update_status_overlay
    end
  end

  def game_over
    @message_window.add_page("#{@pc.name} は力尽きた")
    wait_message_response
    queue do
      # fade_out
      @next_scene = TitleScene
      @dungeon_state = :DO_NOTHING # 決定ボタンで死んでるのに攻撃しちゃう
    end
  end

  def walk
    xstep = (@pc.xpos - @pc.oldx) *2 # 移動した量 × 2 ピクセル
    ystep = (@pc.ypos - @pc.oldy) *2
    i = 0
    if xstep == 0 and ystep == 0 and
        (@moved.empty? or @moved.select {|obj| (@pc.xpos-10..@pc.xpos+10).include? obj.xpos and
        (@pc.ypos-7..@pc.ypos+7).include? obj.ypos}.empty?)
      return
    end
    main_loop do
      @osd.set_text("ターン: #{@turn_count}; フレーム: #{$frame_count}; 状態: #{@dungeon_state.to_s}") # shouldn't have to do this ...
      i += 1
      $field.fill_rect(0,0,640,480, @offscreen_color)
      $miniscreen.fill_rect(0,0,320,240, @offscreen_color)
      fill_screen(@offscreen_color)
      draw_background(@pc.oldx * 32 + xstep * i, @pc.oldy * 32 + ystep * i)
      @objects.each do |obj|
        if @moved.include? obj
          # (x, y) 背景に同期した座標
          x = $cx + (obj.oldx-@pc.oldx) * 32 - xstep*i
          y = $cy + (obj.oldy-@pc.oldy) * 32 - ystep*i
          oxstep = (obj.xpos - obj.oldx) * 2
          oystep = (obj.ypos - obj.oldy) * 2
          obj.draw(x + oxstep*i + 16, y + oystep*i + 16)
        else
          if obj.is_a? Trap and (not @pc.has_state?(:yokumie) and not obj.visible?)
            next
          end
          x = $cx + (obj.xpos-@pc.oldx) * 32 - xstep*i
          y = $cy + (obj.ypos-@pc.oldy) * 32 - ystep*i
          obj.draw(x + 16, y + 16)
        end
      end
      @pc.draw($cx + 16, $cy + 16)
      draw_diagonal_arrows

      Effects.draw

      copy_field_to_screen

      draw_overlay
      @osd.draw
      @message_window.draw

      break if i == 16
    end
#    @pc.position = [xpos, ypos]
  end

  def walk_by_motion
    xstep = (@pc.xpos - @pc.oldx) *2 # 移動した量 × 2 ピクセル
    ystep = (@pc.ypos - @pc.oldy) *2
    i = 0
    if xstep == 0 and ystep == 0 and
        (@moved.empty? or @moved.select {|obj| (@pc.xpos-10..@pc.xpos+10).include? obj.xpos and
        (@pc.ypos-7..@pc.ypos+7).include? obj.ypos}.empty?)
      return
    end

    @objects.each do |obj|
      if @moved.include? obj
        motion = get_walk_motion( obj.direction )
        obj.push_motion motion
      end
    end
#    @pc.position = [xpos, ypos]
    @dungeon_state = :WAIT_MOTION
  end

  def pick_item
    item_picked = nil
    @objects.select{|obj| obj.is_a? Item}.each do |item|
      if [item.xpos, item.ypos] == [@pc.xpos, @pc.ypos]
        if @pc.inventory.full?
          puts "持ち物がいっぱいで持てない"
        else
          item.on_pick(@pc)
          puts "#{item.name} を拾った"
          item_picked = item
        end
      end
    end
    if item_picked
      @objects.delete(item_picked)
    end
  end

  def trap_enter
    @objects.each do |obj|
      if obj.xpos == @pc.xpos and obj.ypos == @pc.ypos
        obj.on_enter(self)
      end
    end
  end

  # ひきのばし
  # まだ書いてない
  def draw_background(xoff = @pc.xpos*32, yoff = @pc.ypos*32)
    return unless Settings.show_background

    @background.draw(xoff - $cx, yoff - $cy, $field)
  end

  def init_floor
    @map = Map.new
    # @map = NiheyaMap.new
    @background.update(@map)
    @pc.position = @map.get_random_place
    @turn_count = 1

    @objects = []
    5.times do
      @objects << Hole.new(*@map.get_random_place)
      @objects << Warp.new(*@map.get_random_place)
      @objects << Mine.new(*@map.get_random_place)
    end
    @objects << Exit.new(*@map.get_random_place)
    10.times do
      # @objects << Enemy.new(*@map.get_random_place, ["ベネフィット","ちんたら","悪い箱"].sample)
      @objects << Enemy.new(*@map.get_random_place, ["ちんたら","悪い箱"].sample)
      @objects.last.change_direction(ALL_DIRECTIONS.sample)
    end
    (5..10).to_a.sample.times do
      @objects << [OtogiriSou, TakatobiSou, MegusuriSou, Yakusou, MoneyBag].sample.new(*@map.get_random_place)
    end

    Mixer.fade_in_music(@dungeon_music, -1, 200)
  end

  def puts(str)
    @message_window.add_page(str)
  end
end
