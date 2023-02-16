require 'open-uri'
require 'yaml'
require_relative 'game.rb'
require_relative 'human_player.rb'
require_relative 'word_generator.rb'

class Control
  def initialize
    @human_player = HumanPlayer.new
    @word_generator = WordGenerator.new
  end

  def run_game
    if game_menu == '1'
      @game = Game.new(@human_player, @word_generator)
    else
      load_game
    end
    @game.play_game
  end

  def game_menu
    puts 'Enter 1 to play a new game. Enter 2 to load a saved game.'
    @human_player.game_mode_input
  end

  def load_game
    create_saved_games_array
    if @saved_games_array.length.postive?
      print_load_menu
      game_number = @human_player.choose_save_game(@saved_games_array.length).to_i
      load_game_file("lib/saved_games/#{@saved_games_array[game_number]}.yaml")
      puts ''
      puts 'Picking up where you left off!'
      puts ''
    else
      puts 'No saved games. Start a new game!'
      @game = Game.new(@human_player, @word_generator)
      @game.play_game
    end
  end

  def create_saved_games_array
    @saved_games_array = []
    Dir.glob('lib/saved_games/**/*').each do |f|
      @saved_games_array << File.basename(f, '.yaml') if File.extname(f) == '.yaml'
    end
  end

  def print_load_menu
    puts 'Saved games:'
    @saved_games_array.each_with_index { |game, index| puts "#{index}: #{game}" }
    puts 'Enter the number of the game you would like to load!'
  end

  def load_game_file(file_name_and_path)
    game_file = File.open(file_name_and_path, 'r')
    yaml = game_file.read
    puts file_name_and_path
    @game = YAML.unsafe_load(yaml)
  end
end
