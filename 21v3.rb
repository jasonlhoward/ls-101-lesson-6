SUITS = [
  ['2660'.hex].pack("U"), # spade
  ['2665'.hex].pack("U"), # heart
  ['2666'.hex].pack("U"), # diamond
  ['2663'.hex].pack("U")  # club
]
RANKS = { 'A' => 1, 'J' => 10, 'Q' => 10, 'K' => 10 }
DEALER_STAYS = 17
WINS_ROUND = 21
WINS_MATCH = 5
MIDDOT = ['00B7'.hex].pack("U")

def joinand(arr)
  first = arr.first
  last = arr.last
  size = arr.size
  result = ''
  if size == 1
    first
  elsif size == 2
    first + ' and ' + last
  else
    (1..size - 2).each do |x|
      result << ', ' + arr[x]
    end
    first + result + ' and ' + last
  end
end

def clear_screen
  system('clear') || system('cls')
end

def show_cards(cards, show_all)
  cards = cards.map { |card| card[:face] }
  if show_all
    joinand(cards)
  else
    return "#{cards[0]} and an unknown card" if cards.size == 2
    "#{cards[0]} and #{cards.size - 1} unknown cards"
  end
end

def rules
  puts "\t#{MIDDOT}Cards 2-10 are face value"
  puts "\t#{MIDDOT}Jacks, Queens and Kings are worth 10"
  puts "\t#{MIDDOT}Aces are worth 1 or 11"
  puts "\t#{MIDDOT}Dealer stays at #{DEALER_STAYS}"
  puts "\t#{MIDDOT}The goal is to reach #{WINS_ROUND} without going over!"
end

def title_and_rules(score)
  width = 60
  puts "=" * width
  puts "Twenty-One\n".center(width)
  puts "Score".center(width)
  puts "You: #{score[:player]}".center(width)
  puts "Dealer: #{score[:dealer]}".center(width)
  puts "=" * width
  rules
  puts "=" * width
end

def show_table(player, dealer, score, show_dealer_cards)
  clear_screen
  title_and_rules(score)
  puts "\nDealer has: #{show_cards(dealer[:hand], show_dealer_cards)}"
  puts "\nYou have: #{show_cards(player[:hand], true)}\n\n"
end

def prompt(message)
  puts "=> #{message}"
end

def initialize_deck
  deck = []
  SUITS.each do |suit|
    RANKS.each_pair do |rank, value|
      deck << { face: "#{rank}#{suit}", rank: rank, value: value }
    end
    (2..10).to_a.each do |value|
      deck << { face: "#{value}#{suit}", rank: value.to_s, value: value }
    end
  end
  deck.shuffle!
end

def deal_card(deck, *participants)
  participants.each { |participant| participant[:hand] << deck.shuffle!.pop }
end

def calc_total(hand)
  ace_count = hand.count { |card| card[:rank] == 'A' }
  total = hand.map { |card| card[:value] }.reduce(:+)
  return total if ace_count.zero?
  total + 10 <= 21 ? total + 10 : total
end

def update_total(*participants)
  participants.each do |participant|
    if participant[:hand].size > participant[:cards_totaled]
      participant[:total] = calc_total(participant[:hand])
      participant[:cards_totaled] = participant[:hand].size
    end
  end
end

def busted?(total)
  total > WINS_ROUND
end

def player_turn!(deck, player, dealer, score)
  loop do
    show_table(player, dealer, score, false)
    choice = nil
    loop do
      prompt("Would you like to 'hit' or 'stay'?")
      choice = gets.chomp
      break if ['stay', 'hit'].include?(choice)
      prompt("Please type 'hit' or 'stay'")
    end
    break if choice == 'stay'
    deal_card(deck, player)
    update_total(player)
    player[:busted] = busted?(player[:total])
    break if player[:busted]
  end
end

def dealer_turn!(deck, player, dealer, score)
  if !player[:busted]
    show_table(player, dealer, score, false)
    loop do
      sleep(1.0)
      show_table(player, dealer, score, false)
      break if dealer[:total] >= DEALER_STAYS
      deal_card(deck, dealer)
      update_total(dealer)
      dealer[:busted] = busted?(dealer[:total])
      break if dealer[:busted]
    end
  end
end

def update_score(score, player, dealer)
  player_total = player[:total]
  dealer_total = dealer[:total]
  if player[:busted]
    score[:dealer] += 1
  elsif dealer[:busted]
    score[:player] += 1
  elsif dealer_total > player_total
    score[:dealer] += 1
  elsif player_total > dealer_total
    score[:player] += 1
  end
end

def compare_cards_and_declare_winner(player, dealer, score)
  show_table(player, dealer, score, true)
  player_total = player[:total]
  dealer_total = dealer[:total]
  if player[:busted]
    puts "You BUSTED with #{player_total}! You LOST this hand!"
  elsif dealer[:busted]
    puts "The dealer BUSTED with #{dealer_total}! You WIN this hand!"
  elsif player_total > dealer_total
    puts "You WON this hand! #{player_total} to #{dealer_total}"
  elsif dealer_total > player_total
    puts "You LOST this hand! #{dealer_total} to #{player_total}"
  else
    puts "It's a TIE! #{dealer_total} to #{player_total}"
  end
end

def match_winner?(score)
  score[:dealer] >= WINS_MATCH || score[:player] >= WINS_MATCH
end

def compare_scores_and_declare_match_winner(score)
  player_score = score[:player]
  dealer_score = score[:dealer]
  if dealer_score >= WINS_MATCH
    puts "You've LOST the match #{dealer_score} to #{player_score}"
  else
    puts "You've WON the match to #{player_score} to #{dealer_score}"
  end
end

def play_again?
  play_again = nil
  loop do
    prompt("Play again? (y or n)")
    play_again = gets.chomp.downcase
    break if ['y', 'n'].include?(play_again)
    prompt("Please type 'y' to play again or 'n' to quit")
  end
  play_again == 'y'
end

def play_hand(score)
  loop do
    deck = initialize_deck
    player = { hand: [], total: 0, cards_totaled: 0, busted: false }
    dealer = { hand: [], total: 0, cards_totaled: 0, busted: false }
    2.times { deal_card(deck, player, dealer) }
    update_total(player, dealer)
    player_turn!(deck, player, dealer, score)
    dealer_turn!(deck, player, dealer, score)
    update_score(score, player, dealer)
    compare_cards_and_declare_winner(player, dealer, score)
    break if match_winner?(score)
    prompt("Hit enter to continue")
    next if gets
  end
end

def play_21
  loop do
    score = { player: 0, dealer: 0 }
    loop do
      play_hand(score)
      break if match_winner?(score)
    end
    compare_scores_and_declare_match_winner(score)
    break unless play_again?
  end
end

play_21
