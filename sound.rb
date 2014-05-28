# -*- coding: utf-8 -*-
require 'sdl'
include SDL

module Sound
  AUDIO_FREQUENCY = 44100
  AUDIO_BUFSIZE = 1024
  @@INITIALIZED_P = false
  @@wav_cache = Hash.new

  def Sound.init
    Mixer.open(AUDIO_FREQUENCY, Mixer::DEFAULT_FORMAT, 2, AUDIO_BUFSIZE)
    @@INITIALIZED_P = true
  end

  # emmit a short beep
  def Sound.beep
    init_check
    Sound.play("data/beep.wav")
  end

  def Sound.play(filename)
    unless File.exist? filename
      printf "Warning: #{filename} does not exist\n"
      filename = "C:/Windows/Media/Windows Ding.wav"
    end
    filename.downcase!
    wav = @@wav_cache[filename] ||= Mixer::Wave.load(filename)

    begin
      Mixer.play_channel(-1, wav, 0)
    rescue SDL::Error
      # 開きチャンネルがなかったようだ
    end
  end

  def Sound.init_check
    raise "you must first initialize the sound module by calling Sound.init" unless @@INITIALIZED_P
  end
end

