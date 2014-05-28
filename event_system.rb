# -*- coding: utf-8 -*-
# my third attempt

module EventSystem
  # リスナーレジストリ
  # イベント名 Symbol をキーとして、
  # 関心を示したオブジェクトの ID の配列を持つ。
  # それぞれのオブジェクトは Event モジュールを include している。
  @@registry = Hash.new

  class Event
    attr_reader :type, :args

    def initialize(type, args)
      @type = type
      @args = args
    end
  end

  def EventSystem.broadcast_event(name, *args)
    interested = @@registry[name]
    return unless interested # there's no-one interested in this type of event

    event = EventSystem::Event.new(name, args)
    # 関心を登録したオブジェクトのイベントハンドラーを
    # 呼び出し、オブジェクトがすでに GC されていた場合は、
    # リストから削除する。
    interested.select! do |id|
      begin
        obj = ObjectSpace._id2ref(id)
        obj.event_handler(event)
        true # 残す
      rescue RangeError
        puts "recycled object in the registry. discarding"
        false # 破棄する
      end
    end
  end

  def EventSystem.unregister_listener(obj)
    id = obj.object_id
    @@registry.each_value do |ary|
      ary.delete(id)
    end
  end

  def EventSystem.dump_registry
    puts @@registry.inspect
  end

  # コールバック Proc を登録する
  def register_callback(name, &block)
    (@@registry[name] ||= []) << self.object_id
    (@event_callback_map ||= {})[name] = block
  end

  def event_handler(event)
    map = @event_callback_map
    return unless map
    return unless map[event.type]
    map[event.type].call(*event.args)
  end
end

# ーーー 以下実例

class GameObject
  include EventSystem
end

a = GameObject.new
b = GameObject.new
c = GameObject.new

# :some_event イベントにコールバックを登録する
a.register_callback(:some_event) do |i, j|
  puts "a: #{i}, #{j}"
end
b.register_callback(:some_event) do |i, j|
  puts "b: #{i}, #{j}"
end
c.register_callback(:some_event) do |i, j|
  puts "c: #{i}, #{j}"
end

# a を開放する
a = nil
GC.start
# b の登録を解除する
EventSystem.unregister_listener(b)

# c のコールバックだけが呼ばれるはず
EventSystem.broadcast_event(:some_event, 123, 456)
