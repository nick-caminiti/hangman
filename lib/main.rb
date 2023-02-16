# require 'open-uri'
# require 'yaml'
require_relative 'control.rb'
require_relative 'game.rb'
require_relative 'human_player.rb'
require_relative 'word_generator.rb'

control = Control.new
control.run_game