class RPSGame
  attr_accessor :human, :computer
  attr_reader :winning_score

  def initialize(winning_score)
    @winning_score = winning_score
    @human = Human.new
    @computer = Computer.new
  end

  def play
    display_welcome_message
    loop do
      until human.score == winning_score || computer.score == winning_score
        play_round
        display_scores
      end
      break unless play_again?
      human.score, computer.score = 0, 0
    end
    display_goodbye_message
    # display_move_history
  end

  def play_round
    human.choose
    computer.choose
    display_moves
    display_winner
    increment_score
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)?"
      answer = gets.chomp
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n."
    end
    answer == 'y'
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
  end

  def display_goodbye_message
    winner_name = human.score == winning_score ? human.name : computer.name
    puts "#{winner_name} won #{winning_score} rounds!"
    puts "#{winner_name} won the game!"
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
  end

  def display_moves
    puts "#{human.name} chose: #{human.move}"
    puts "#{computer.name} chose: #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_move_history
    puts "#{human.name} has played these moves: #{human.move_history}"
    puts "#{computer.name} has played these moves: #{computer.move_history}"
  end

  def increment_score
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end
end

def display_scores
  puts "#{human.name} has won #{human.score} rounds!"
  puts "#{computer.name} has won #{computer.score} rounds!"
end

class Player
  attr_accessor :move, :name, :score, :move_history

  def initialize
    set_name
    @score = 0
    @move_history = []
  end
end

class Human < Player
  def set_name
    name = nil
    loop do
      puts "What's your name?"
      name = gets.chomp
      break unless name.empty?
      puts "Sorry, must enter a value"
    end
    self.name = name
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock, or lizard: "
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Invalid choice."
    end

    class_name = Kernel.const_get(choice.capitalize)
    self.move = class_name.new
    self.move_history << self.move
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny'].sample
  end

  def choose
    class_name = Kernel.const_get(Move::VALUES.sample.capitalize)
    self.move = class_name.new
    self.move_history << self.move
  end
end

class Move
  attr_reader :loses_to, :wins_against

  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

  def >(other_move)
    wins_against.include?(other_move.class)
  end

  def <(other_move)
    loses_to.include?(other_move.class)
  end

  def to_s
    self.class.to_s
  end
end

class Rock < Move
  def initialize
    @loses_to = [Paper, Spock]
    @wins_against = [Scissors, Lizard]
  end
end

class Paper < Move
  def initialize
    @loses_to = [Lizard, Scissors]
    @wins_against = [Rock, Spock]
  end
end

class Scissors < Move
  def initialize
    @loses_to = [Rock, Spock]
    @wins_against = [Paper, Lizard]
  end
end

class Spock < Move
  def initialize
    @loses_to = [Lizard, Paper]
    @wins_against = [Rock, Scissors]
  end
end

class Lizard < Move
  def initialize
    @loses_to = [Rock, Scissors]
    @wins_against = [Paper, Spock]
  end
end

RPSGame.new(3).play

=begin
RPS Bonus Features

- Keeping Score
  - whoever reaches 10 points first wins
  - wins can be a state of a player
  - number to play to can be a state of the game

- Add Lizard and Spock
  - rubocop is complaining about our > function
  - I'll address this after creating a class for each move

- Add a class for each move
  - can inherit from Move class
  - can each have a defeats list that will be utilized in the
  - thoughts:
    - The attr_reader for @loses_to and @wins_against seems weird to put in the Move class, but it would be a lot of repitition to put it in each class, especially when it works to put it in Move

- Keep track of a history of moves
  - need to reimplement play_again? before this has purpose
  - successfully kept track of move history, but when using interpolation on an array, it seems that to_s is called on the array object, not each object within the array. Hoping to find a way to fix this without iterating over each element of move_history

- Computer Personalities
  - I would consider creating a hash that contains the computer character name as a key and the attributes as values. Maybe an array of catch phrases to randomly throw out during play. A favorite moves array or least favorite moves array that are chosen less often. The attribute types should be the same for each hash value so we can populate different instance variables upon instantiation of a computer opponent.
=end
