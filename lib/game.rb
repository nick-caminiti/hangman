require 'open-uri'
require 'yaml'
require_relative 'human_player.rb'
require_relative 'word_generator.rb'
require_relative 'control.rb'
require_relative 'save_game.rb'

class Game
  include SaveGame

  def initialize(human_player, word_generator)
    @human_player = human_player
    @word_generator = word_generator
    @game_set = false
    @save_character = '*' # not linked to regex for user input
  end

  def play_game
    game_setup unless @game_set
    while @solved == false && @misses < 6
      if play_round == @save_character
        save_game = true
        break
      end
      @round += 1
    end
    if save_game
      save_game_menu
      control = Control.new
      control.run_game
    else
      print_game_result
      File.delete(@loaded_file_name) if @loaded_game
    end
  end

  def game_setup
    @word_generator.load_dictionary unless File.exist?('dictionary-data.txt')
    @secret_word = @word_generator.choose_secret_word
    @round = 1
    @word_array = Array.new(@secret_word.length, '_')
    @solved = false
    @misses = 0
    @guesses = []
    @game_set = true
  end

  def play_round
    puts "Round #{@round}"
    print_man
    print_word_current_state
    print_prior_guesses unless @round == 1
    latest_guess = prompt_for_guess
    unless latest_guess == @save_character
      @guesses << latest_guess
      update_word_array(latest_guess)
      check_for_winner
    end
    latest_guess
  end

  def print_game_result
    if @solved == true
      print_word_current_state
      puts 'You win!'
    else
      print_man
      puts "You lose :( The word was #{@secret_word}"
    end
  end

  def check_for_winner
    @solved = true unless @word_array.include?('_')
  end

  def update_word_array(guess)
    if find_if_guess_included(guess)
      array_of_index = find_index_of_guess(guess)
      replace_dashes_in_word_array(guess, array_of_index)
    end
  end

  def replace_dashes_in_word_array(guess, array_of_index)
    array_of_index.each do |index|
      @word_array[index] = guess
    end
  end

  def find_if_guess_included(guess)
    if @secret_word.include?(guess)
      true
    else
      @misses += 1
      false
    end
  end

  def find_index_of_guess(guess)
    (0...@secret_word.length).find_all { |i| @secret_word[i, 1] == guess }
  end

  def prompt_for_guess
    puts 'Guess a letter! Or enter * to save the game'
    new_letter_check = 'fail'
    until new_letter_check == 'pass'
      entry = @human_player.guess_input
      if @guesses.include?(entry)
        puts 'You already guessed that! Try again!'
      else
        new_letter_check = 'pass'
      end
    end
    entry
  end

  def print_prior_guesses
    print 'Your prior guesses: '
    @guesses.each{ |guess| print "#{guess} " }
    puts ''
  end

  def print_man
    puts  ''
    create_man_array
    @man_array.each { |row| puts row }
  end

  def print_word_current_state
    puts ''
    @word_array.each { |letter| print " #{letter}" }
    puts ''
    puts ''
  end

  def create_man_array
    create_man_array_template
    create_miss_dictionary
    current_miss_dictionary = {}
    @miss_dictionary.each do |key, value|
      current_miss_dictionary[key] = if key.to_i <= @misses.to_i
                                       value
                                     else
                                       ' '
                                     end
    end
    @man_array = @man_array_template.map { |row| row.gsub(/[1-6}]/, current_miss_dictionary) }
  end

  def create_man_array_template
    @man_array_template = [
      '  +-----+ ',
      '  |     | ',
      ' 314    | ',
      '  2     | ',
      ' 5 6    | ',
      '       / \\'
    ]
  end

  def create_miss_dictionary
    @miss_dictionary = {
      '1' => '0',
      '2' => '|',
      '3' => '\\',
      '4' => '/',
      '5' => '/',
      '6' => '\\'
    }
  end

end