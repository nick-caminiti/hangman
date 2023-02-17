# frozen_string_literal: true

require_relative 'control'
require_relative 'game'
require_relative 'human_player'
require_relative 'word_generator'

control = Control.new
control.run_game