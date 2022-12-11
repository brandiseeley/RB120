require 'pry-byebug'
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def [](num)
    @squares[num]
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def unmarked_keys_sentence
    available_squares = unmarked_keys
    return available_squares[0].to_s if available_squares.size == 1
    "#{available_squares[0...-1].join(', ')}, or #{available_squares[-1]}"
  end

  # returns the keys for any squares that, if marked, would create a win for the input marker: if 'X' is in squares 1 & 2, and square 3 is empty, squares_to_win would return 3
  def squares_to_win(marker)
    # binding.pry
    square_keys = []
    WINNING_LINES.each do |line|
      markers = line.map { |key| @squares[key].marker }
      if markers.count(marker) == 2 && markers.count(' ') == 1
        # binding.pry
        square_keys << line[markers.index(' ')]
      end
    end
    square_keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |       1 | 2 | 3"
    puts "-----+-----+-----  ---------"
    puts "     |     |       4 | 5 | 6"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}    ---------"
    puts "     |     |       7 | 8 | 9"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name
  attr_accessor :rounds_won

  def initialize(marker)
    @marker = marker
    @name = nil
    @rounds_won = 0
  end
end

class TTTGame
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer

  def initialize(rounds_to_win=3)
    @board = Board.new
    @human = Player.new(nil)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = nil
    @round = 1
    @rounds_to_win = rounds_to_win
    @who_starts = nil

  end

  def play
    clear
    display_welcome_message
    choose_names
    choose_markers
    coin_toss
    main_game
    display_goodbye_message
  end

  private

  def choose_markers
    marker = nil
    loop do
      puts "Please choose a marker, it can be any single letter or symbol:"
      marker = gets.chomp
      break if marker.length == 1
      puts "Sorry, invalid marker."
    end
    human.marker = marker
    computer_markers = ['X', 'O']
    computer_markers.delete(human.marker.upcase)
    computer.marker = computer_markers.sample
    puts "You chose #{human.marker}. Computer chose #{computer.marker}"
  end

  def choose_names
    name = nil
    loop do
      puts "Please enter your name: "
      name = gets.chomp
      break unless name.empty?
      puts "Sorry, you must enter something."
    end
    @human.name = name
    @computer.name = ['R2D2', 'Johnny 5', 'beep boop', 'ex machina'].sample
    puts "Hello #{@human.name}, you'll be playing against #{computer.name}."
  end

  def coin_toss
    toss = ['heads', 'tails'].sample
    choice = nil
    loop do
      puts "Choose heads or tails!"
      choice = gets.chomp
      break if ['heads', 'tails'].include?(choice)
      puts "Sorry, invalid answer."
    end
    @current_marker = choice == toss ? @human.marker : @computer.marker
    @who_starts = choice == toss ? @human.marker : @computer.marker
    if toss == choice
      puts "#{toss}! You'll start, #{human.name}!"
    else
      puts "#{toss}! Computer starts!"
    end
    sleep 2
  end

  def main_game
    @current_marker = @who_starts
    loop do
      display_board
      player_move
      score_round
      display_result
      break if n_rounds_won?(@rounds_to_win)
      reset
      display_play_again_message
    end
  end

  def n_rounds_won?(n)
    human.rounds_won == n || computer.rounds_won == n
  end

  def score_round
    human.rounds_won += 1 if board.winning_marker == human.marker
    computer.rounds_won += 1 if board.winning_marker == COMPUTER_MARKER
    @round += 1
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == human.marker
  end

  def display_board
    puts "Round #{@round}! #{human.name}: #{human.rounds_won}, #{computer.name}: #{computer.rounds_won}"
    puts "You're a #{human.marker}. #{computer.name} is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "#{human.name}, choose a square (#{board.unmarked_keys_sentence}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    # check for immediate wins
    wins = board.squares_to_win(COMPUTER_MARKER)
    threats = board.squares_to_win(human.marker)
    if !wins.empty?
      board[wins.sample] = computer.marker
    elsif !threats.empty?
      # check for immediate threats
      board[threats.sample] = computer.marker
    elsif board[5].marker == ' '
      board[5] = computer.marker
    else
      board[board.unmarked_keys.sample] = computer.marker if threats.empty?
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
    if computer.rounds_won == @rounds_to_win
      puts "Computer won #{@rounds_to_win} rounds! You lose!"
    elsif human.rounds_won == @rounds_to_win
      puts "You won #{@rounds_to_win} rounds! Congratulations, #{human.name}!"
    end
    #slow clear
    sleep 2
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @who_starts = @who_starts == COMPUTER_MARKER ? human.marker : COMPUTER_MARKER
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
