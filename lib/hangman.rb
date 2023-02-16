require 'open-uri'
require 'yaml'

class Game
  def initialize
    @human_player = HumanPlayer.new
    @computer = Computer.new
    @game_set = false
    @save_character = '*' # not linked to regex for user input
  end

  def load_dictionary
    dictionary_url = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt'
    remote_dictionary = URI.open(dictionary_url).read

    local_dictionary = open('dictionary-data.txt', 'w')

    local_dictionary.write(remote_dictionary)
    local_dictionary.close
  end

  def game_setup
    load_dictionary unless File.exist?('dictionary-data.txt')
    @secret_word = @computer.choose_secret_word
    @round = 1
    @word_array = Array.new(@secret_word.length, '_')
    @solved = false
    @misses = 0
    @guesses = []
    @game_set = true
  end

  def save_game_menu
    puts 'Enter a name for your saved game.'
    file_name = @human_player.name_save_game
    puts file_name
    yaml = YAML.dump(self)
    file_path = "lib/saved_games/#{file_name}.yaml"
    game_file = File.open(file_path, 'w')
    game_file.write(yaml)
    game_file.close
    puts "game saved as: #{file_name}"
  end

  def load_game
    create_saved_games_array
    if @saved_games_array.length > 0
      print_load_menu
      game_number = @human_player.choose_save_game(@saved_games_array.length).to_i
      load_game_file("lib/saved_games/#{@saved_games_array[game_number]}.yaml")
      puts ''
      puts 'Picking up where you left off!'
      puts ''
    else
      puts 'No saved games. Start a new game!'
      play_game
    end
  end

  def load_game_file(file_name_and_path)
    game_file = File.open(file_name_and_path, 'r')
    yaml = game_file.read
    @loaded_game = YAML.unsafe_load(yaml)
  end

  def create_saved_games_array
    @saved_games_array = []
    Dir.glob('lib/saved_games/**/*').each do |f|
      if File.extname(f) == '.yaml'
        @saved_games_array << File.basename(f, '.yaml')
      end
    end
  end

  def print_load_menu
    puts 'Saved games:'
    @saved_games_array.each_with_index { |game, index| puts "#{index}: #{game}" }
    puts 'Enter the number of the game you would like to load!'
  end

  def game_menu
    puts 'Enter 1 to play a new game. Enter 2 to load a saved game.'
    @human_player.game_mode_input
  end

  def run_game
    if game_menu == '1'
      play_game
    else
      load_game
      @loaded_game.play_game
    end
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
      run_game
    else
      print_game_result
    end
    File.delete(@loaded_file_name) if @loaded_game
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
    print_man
    puts  ''
  end

  def print_word_current_state
    puts  ''
    @word_array.each { |letter| print " #{letter}" }
    puts  ''
    puts  ''
  end

  def print_man
    man_array = [
      '  +-----+ ',
      '  |     | ',
      ' 314    | ',
      '  2     | ',
      ' 5 6    | ',
      '       / \\'
    ]

    miss_dictionary = {
      '1' => '0',
      '2' => '|',
      '3' => '\\',
      '4' => '/',
      '5' => '/',
      '6' => '\\'
    }
    current_miss_dictionary = {}
    miss_dictionary.each do |key, value|
      current_miss_dictionary[key] = if key.to_i <= @misses.to_i
                                       value
                                     else
                                       ' '
                                     end
    end
    man_array = man_array.map { |row| row.gsub(/[1-6}]/, current_miss_dictionary) }
    man_array.each { |row| puts row }
  end
end

class Computer
  def initialize; end

  def return_random_word
    dictionary = 'dictionary-data.txt'
    words = File.open(dictionary, 'r')
    lines = File.foreach(words).count
    IO.readlines(dictionary)[rand(0..(lines - 1))].chomp
  end

  def choose_secret_word
    word_length = 0
    until word_length >= 5 && word_length <= 12
      secret_word = return_random_word
      word_length = secret_word.length
    end
    secret_word
  end
end

class HumanPlayer
  def initialize; end

  def guess_input
    pass = 0
    until pass == 1
      begin
        guess = Kernel.gets.chomp.match(/^[a-zA-Z*]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your entry must be a single letter. Please try again.'
      else
        pass = 1
        return guess.downcase
      end
    end
  end

  def game_mode_input
    pass = 0
    until pass == 1
      begin
        guess = Kernel.gets.chomp.match(/^[12]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your entry must be 1 or 2. Please try again.'
      else
        pass = 1
        return guess.downcase
      end
    end
  end

  def name_save_game
    pass = 0
    until pass == 1
      begin
        input = gets.chomp.match(/^\w{3,8}$/)[0]
      rescue StandardError => _e
        puts 'Your entry must consist of numbers and letter and be between 3 and 8 characters with no spaces.'
      else
        pass = 1
        return input.downcase
      end
    end
  end

  def choose_save_game(options)
    pass = 0
    until pass == 1
      begin
        input = gets.chomp.match(/^[0-#{options-1}]{1}$/)[0]
      rescue StandardError => _e
        puts 'Your entry must correspond to a saved game.'
      else
        pass = 1
        return input.downcase
      end
    end
  end

end

game = Game.new
game.run_game

# human_player = HumanPlayer.new
# human_player.name_save_game_input