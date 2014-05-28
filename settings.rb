# -*- coding: utf-8 -*-
module Settings
  @@settings = Hash.new
  @@default_values = Hash.new
  @@labels = Hash.new

  def self.define_var(sym, defval, label = name) 
    @@settings[sym] = defval
    @@default_values[sym] = defval
    @@labels[sym] = label
    self.module_eval("def self.#{sym}; @@settings[:#{sym}]; end")
    self.module_eval("def self.#{sym}=(val); @@settings[:#{sym}]=val; end")
  end

  define_var :worldview_zoom, false, 'ワールドの拡大表示'
  define_var :overlay_enabled, true, 'オーバーレイマップの表示'
  define_var :show_background, true, '背景の表示'

  def self.value_for(sym)
    @@settings[sym]
  end

  def self.label_for(sym)
    @@labels[sym]
  end

  def self.variables
    @@settings.keys
  end

  def self.save
    changed_settings = Hash.new
    @@settings.each_key do |key|
      if @@settings[key] != @@default_values[key]
        changed_settings[key] = @@settings[key]
      end
    end
    str = Marshal.dump(changed_settings)
    File.open('settings.dat', 'wb') do |f|
      f.write str
    end
  end

  def self.load
    File.open('settings.dat', 'rb') do |f|
      str = f.read
      @@settings.merge!( Marshal.load(str) )
    end
  end
end
