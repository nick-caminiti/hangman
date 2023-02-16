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