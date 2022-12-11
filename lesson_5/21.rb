class TwentyoneGame
  attr_reader :human, :dealer, :deck

  def initialize
    @deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
  end

  def play
    display_welcome_message
    deal_cards
    dealer.display_cards_hidden
    human.display_cards
    human.take_turn(deck)
    dealer.take_turn(deck) unless human.bust?
    display_results
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to 21!"
  end

  def display_results
    dealer.display_cards
    human.display_cards
    if human.bust?
      puts "You busted, better luck next time!"
    elsif dealer.bust?
      puts "Dealer busted, you win!"
    elsif human.total > dealer.total
      puts "You won! You scored #{human.total}, the dealer scored #{dealer.total}"
    elsif dealer.total > human.total
      puts "Dealer Won! They scored #{dealer.total}, you scored #{human.total}"
    else
      puts "It's a tie! You both scored #{human.total}"
    end
  end

  def display_goodbye_message
    puts "Thanks for playing, Goodbye!"
  end

  def deal_cards
    human.cards = deck.draw(2)
    dealer.cards = deck.draw(2)
  end
end

class Player
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def hit(deck)
    cards << deck.draw_one
  end

  def display_cards
    card_strings = cards.map do |card|
      card.rank.to_s + ' ' * (5 - card.rank.to_s.length)
    end

    special_string = ""
    card_strings.each do |card|
      special_string += "  | #{card} |"
    end

    num_cards = cards.size

    puts "Your hand:" if self.class == Human
    puts "Dealer's hand:" if self.class == Dealer
    puts "  +-------+" * num_cards
    puts "  |       |" * num_cards
    puts special_string
    puts "  |       |" * num_cards
    puts "  +-------+" * num_cards
  end

  def bust?
    total > 21
  end

  def total
    total = 0
    cards.each { |card| total += card.value }

    cards.each do |card|
      total -= 10 if card.rank == 'ace' && total > 21
    end
    total
  end
end

class Dealer < Player
  def take_turn(deck)
    loop do
      break if bust? || total > 17
      hit(deck)
    end
  end

  def display_cards_hidden
    first_card = cards[0]
    card_string = first_card.rank.to_s + ' ' * (5 - first_card.rank.to_s.length)

    special_string = "  | #{card_string} |  |   ?   |"

    puts "Dealers Hand:"
    puts "  +-------+" * 2
    puts "  |       |" * 2
    puts special_string
    puts "  |       |" * 2
    puts "  +-------+" * 2
  end
end

class Human < Player
  def take_turn(deck)
    loop do
      move = prompt_hit_or_stay
      hit(deck) if move == 'hit'
      break if bust? || move == 'stay'
      display_cards
    end
    display_cards if bust?
    puts "You Busted!" if bust?
  end

  def prompt_hit_or_stay
    move = nil
    loop do
      puts "hit or stay?"
      move = gets.chomp
      break if ['hit', 'stay'].include?(move)
    end
    move
  end
end

RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace']
SUITS = ['spades', 'clubs', 'diamonds', 'hearts']
class Deck
  attr_reader :cards

  def initialize
    @cards = fresh_deck
  end

  def fresh_deck
    deck = []
    SUITS.each do |suit|
      RANKS.each do |rank|
        deck << Card.new(rank, suit)
      end
    end
    deck
  end

  # mutates deck AND returns one card
  def draw_one
    shuffle!
    @cards.pop
  end

  # mutates deck AND returns <quantity> cards
  def draw(quantity)
    cards = []
    quantity.times { |_| cards << draw_one }
    cards
  end

  def shuffle!
    @cards.shuffle!
  end
end

VALUES = { 'jack' => 10, 'queen' => 10, 'king' => 10, 'ace' => 11 }
class Card
  attr_reader :rank

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank} of #{@suit}"
  end

  def value
    if VALUES.include?(@rank)
      VALUES[@rank]
    else
      @rank
    end
  end
end

game = TwentyoneGame.new
game.play
