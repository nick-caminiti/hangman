class WordGenerator
  def initialize; end

  def load_dictionary
    dictionary_url = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt'
    remote_dictionary = URI.open(dictionary_url).read

    local_dictionary = open('dictionary-data.txt', 'w')

    local_dictionary.write(remote_dictionary)
    local_dictionary.close
  end

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