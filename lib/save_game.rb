# frozen_string_literal: true

module SaveGame
  def save_game_menu
    puts 'Enter a name for your saved game.'
    file_name = @human_player.name_save_game
    yaml = YAML.dump(self)
    file_path = "lib/saved_games/#{file_name}.yaml"
    game_file = File.open(file_path, 'w')
    game_file.write(yaml)
    game_file.close
    puts "game saved as: #{file_name}"
  end
end
