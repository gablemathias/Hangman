require 'yaml'

class Hangman
  attr_accessor :hangman, :wrong_words

  def initialize
    @word        = random_word
    @hangman     = Array.new(@word.size, '_')
    @words       = @word.split(//)
    @guesses     = 8
    @wrong_words = []
  end

  def play
    puts "You have #{@guesses} guesses. Use them wisely!\n"
    puts " #{hangman.join(' ')} "

    loop do
      puts "Make a guess or type 'save' to save the game"
      guess = gets.chomp.downcase
      save if guess == 'save'
      break if guess == 'save'
      puts "\n"
      next if already?(guess)

      word.include?(guess) ? fill(guess) : wrong_words << guess

      puts "( #{@hangman.join(' ')} )"
      @guesses -= 1
      puts "\nGuesses left: #{@guesses}"
      puts "Wrong guesses: #{wrong_words.join(",")}"
      next if guesses_left?
      break try
    end
  end

  private
  attr_reader :word, :words

  def random_word
    File.read('google-10000-english-no-swears.txt')
        .split("\n")
        .select { |w| w.length >= 5 && w.length <= 12 }
        .sample
  end

  def win
    puts "Correct! You won the game!"
  end

  def lose
    puts "Incorrect :( The correct word is: #{word}.\nYou lose!"
  end

  def fill(guess)
    words.each_with_index do |w, i|
      hangman[i] = guess if w == guess
    end
  end

  def guesses_left?
    @guesses > 0 && hangman.any?('_')
  end

  def already?(guess)
    if hangman.include?(guess) || wrong_words.include?(guess)
      puts "you already guessed this letter"
      true
    end
  end

  def discovered?
    hangman.any?('_')
  end

  def try
    puts "You run out of guesses. What's the word?"
    try = gets.chomp.downcase
    try == word ? win : lose
  end

  def save
    loop do
      print "Name the game you wanna save: "
      name = gets.chomp
      next if exists?(name)


      dump = YAML.dump(self)
      File.open("./saves/#{name}.yaml","w") {|f| f.write dump}
      break quit
    end
  end

  def exists?(name)
    if File.exists?("./saves/#{name}.yaml")
      dont_overwrite?
    else
      false
    end
  end

  def dont_overwrite?
    puts "Do you want to overwrite the file? yes | no"
    choice = gets.chomp
    choice[0].downcase != 'y' # return false if yes
  end

  def self.load(game)
    saved = File.read("./saves/#{game}.yaml")
    YAML.load(saved).play
  end

  def quit
    puts "Goodbye!"
  end

end


# The Game

puts "Welcome to Hangman!"
puts "Do you want to load a game or start a new one? (CTRL-D to exit)"

loop do
  puts "1 to start a new game | 2 to load game | 3 to exit"
  choice = gets.chomp
  case choice
  when '1'
    the_game = Hangman.new
    the_game.play
  when '2'
    begin
    files = Dir.glob("./saves/*yaml")
            .map{ |f| f.sub("./saves/", "").chomp(".yaml") }
            .join("\n")
    print "Choose the saved file:\n#{files}\n=> "
    file = gets.chomp.downcase
    if files.include?(file)
      Hangman.load(file)
    end
    rescue => exception
      puts "Choose a correct name"
      retry
    end
  when '3'
    break puts "Goodbye!"
  else
    next puts "Invalid input, try again"
  end
end
