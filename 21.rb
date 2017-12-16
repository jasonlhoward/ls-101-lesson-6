# build the deck
SUITS = { 'hearts' => "1F0B",
          'diamonds' => "1F0C",
          'clubs' => "1F0D",
          'spades' => "1F0A" }
RANKS = { 'ace' => { value: 1, code: '1' },
          '2' => { value: 2, code: '2' },
          '3' => { value: 3, code: '3' },
          '4' => { value: 4, code: '4' },
          '5' => { value: 5, code: '5' },
          '6' => { value: 6, code: '6' },
          '7' => { value: 7, code: '7' },
          '8' => { value: 8, code: '8' },
          '9' => { value: 9, code: '9' },
          '10' => { value: 10, code: 'A' },
          'jack' => { value: 10, code: 'B' },
          'queen' => { value: 10, code: 'D' },
          'king' => { value: 10, code: 'E' } }
BACK_OF_CARD = ["1F0A0".hex].pack("U")

def prompt(message)
  puts "=> #{message}"
end

def valid_choice?(input)
  ['hit', 'stay'].include?(input.downcase)
end

def initialize_deck
  deck = []
  SUITS.each_pair do |suit, suit_code|
    RANKS.each_pair do |rank, details|
      image = suit_code + details[:code]
      deck << { suit: suit,
                image: [image.hex].pack("U"),
                rank: rank,
                value: details[:value] }
    end
  end
  deck.shuffle!
end

def hand_total(hand)
  total = 0
  ace_count = 0
  hand.each do |hsh|
    hsh[:rank] == 'ace' ? ace_count += 1 : total += hsh[:value]
  end
  if ace_count > 0
    ace_total_max = ace_count + total + 10
    ace_total_min = ace_count + total
    ace_total_max <= 21 ? ace_total_max : ace_total_min
  else
    total
  end
end

def deal_card(table)
  table[:deck].shuffle!.pop
end

def player_turn(table)
  if table[:player][:position] == 'hit'
    choice = nil
    loop do
      prompt("Would you like to 'hit' or 'stay'?")
      choice = gets.chomp
      break if valid_choice?(choice)
      prompt("Please type 'hit' or 'stay'")
    end
    table[:player][:hand] << deal_card(table) if choice == 'hit'
    table[:player][:position] = choice
  end
end

def dealer_turn(table)
  dealer_total = hand_total(table[:dealer][:hand])
  table[:dealer][:position] = 'stay' if dealer_total >= 17
  if table[:dealer][:position] == 'hit'
    table[:dealer][:hand] << deal_card(table)
    table[:dealer][:position] = 'stay' if dealer_total >= 17
  end
end

def initial_deal(table)
  2.times do
    table[:dealer][:hand] << deal_card(table)
    table[:player][:hand] << deal_card(table)
  end
end

def player_cards(table)
  table[:player][:hand].map { |cards| cards[:image] }
end

def dealer_cards(table, show_all = false)
  if show_all
    cards = table[:dealer][:hand].map { |hsh| hsh[:image] }
  else
    cards = []
    table[:dealer][:hand].each_with_index do |hsh, index|
      image = index.zero? ? hsh[:image] : BACK_OF_CARD
      cards << image
    end
  end
  cards
end

def clear_screen
  system('clear') || system('cls')
end

# rubocop:disable Metrics/AbcSize
def show_table(table, show_all = false)
  clear_screen
  dealer_position = table[:dealer][:position]
  dealer_position = 'Dealer stays' if dealer_position == 'stay'
  dealer_position = '' if show_all || dealer_position == 'hit'
  puts ""
  puts "   " + dealer_cards(table, show_all).join('  ') + '  ' + dealer_position
  puts " ------------------------"
  puts "|                        | - Cards 2-10 are face value"
  puts "|                        | - Jacks, Queens and Kings are worth 10"
  puts "|       Twenty-One       | - Aces are worth 1 or 11"
  puts "|                        | - Dealer stays at 17"
  puts "|                        | - First to 21 wins!"
  puts " ------------------------"
  puts "   " + player_cards(table).join('  ')
  puts ""
end

# rubocop:enable Metrics/AbcSize

def both_stay?(table)
  table[:dealer][:position] == 'stay' && table[:player][:position] == 'stay'
end

def take_a_turn(turn, table)
  if turn == 'player'
    player_turn(table)
  else
    dealer_turn(table)
  end
  show_table(table)
  turn == 'player' ? 'dealer' : 'player'
end

def busted?(table)
  dealer_total = hand_total(table[:dealer][:hand])
  player_total = hand_total(table[:player][:hand])
  dealer_total > 21 || player_total > 21
end

def game_over?(table)
  both_stay?(table) || busted?(table)
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
def end_of_game_messages(table)
  show_table(table, true)
  dealer_total = hand_total(table[:dealer][:hand])
  player_total = hand_total(table[:player][:hand])
  if busted?(table)
    if dealer_total > 21
      puts "The dealer hit #{dealer_total} and busted! You win!"
    else
      puts "You hit #{player_total} and busted! You lost!"
    end
  elsif both_stay?(table)
    puts "The dealer scored #{dealer_total}"
    puts "You scored #{player_total}"
    if dealer_total > player_total
      puts "You LOST!"
    elsif player_total > dealer_total
      puts "You WIN!"
    else
      puts "It's a TIE!"
    end
  end
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity

loop do
  table = {
    deck: initialize_deck,
    dealer: { hand: [], position: 'hit' },
    player: { hand: [], position: 'hit' }
  }
  initial_deal(table)
  turn = 'player'
  loop do
    show_table(table)
    turn = take_a_turn(turn, table)
    break if game_over?(table)
    next
  end
  end_of_game_messages(table)
  prompt("Deal again? (n or [Any]")
  break if gets.chomp.downcase.start_with?('n')
end

prompt("Thanks for playing Twenty-One! Goodbye!")
