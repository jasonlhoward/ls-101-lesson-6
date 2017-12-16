INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
PLAYER = 'Player'
COMPUTER = 'Computer'
TIE = 'Tie'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # across
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # down
                [[1, 5, 9], [3, 5, 7]]              # diagonal
IMMINENT_WIN = 45
IMMINENT_LOSS = 22
POSSIBLE_WIN = 10
POSSIBLE_LOSS = 4
IMPROBABLE_WIN = 2
IMPOSSIBLE_WIN_OR_LOSS = 1

def joinor(arr, delimiter)
  arr.map!(&:to_s)
  first = arr.first
  last = arr.last
  size = arr.size
  result = ''
  if size == 1
    first
  elsif size == 2
    first + ' or ' + last
  else
    (1..size - 2).each do |x|
      result << delimiter + ' ' + arr[x]
    end
    first + result + ' or ' + last
  end
end

def prompt(message)
  puts "=> #{message}"
end

# rubocop:disable Metrics/LineLength
def marquee(score)
  system('clear') || system('cls')
  puts " -------------------"
  puts "|                   | - You're #{PLAYER_MARKER} and the computer is #{COMPUTER_MARKER}"
  puts "|    Tic-Tac-Toe    | - 5 wins, losses or ties ends the match."
  puts "|                   | - Wins: #{score[PLAYER]} Losses: #{score[COMPUTER]} Ties: #{score[TIE]}"
  puts " -------------------"
end

# rubocop:disable Metrics/AbcSize
def display_board(board, score)
  marquee(score)
  puts ""
  puts "     |     |               |     |"
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}         7  |  8  |  9"
  puts "     |     |               |     |"
  puts "-----+-----+-----     -----+-----+-----"
  puts "     |     |               |     |"
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}         4  |  5  |  6"
  puts "     |     |               |     |"
  puts "-----+-----+-----     -----+-----+-----"
  puts "     |     |               |     |"
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}         1  |  2  |  3"
  puts "     |     |               |     |"
  puts ""
end

# rubocop:enable Metrics/AbcSize, Metrics/LineLength

def initialize_board
  new_board = {}
  (1..9).each { |x| new_board[x] = INITIAL_MARKER }
  new_board
end

def open_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def board_full?(board)
  open_squares(board).empty?
end

def valid_input?(input, board)
  open_squares(board).include?(input)
end

def winner?(board)
  !!detect_winner(board)
end

def detect_winner(board)
  WINNING_LINES.each do |arr|
    arr = arr.map { |x| board[x] }
    next unless arr.uniq.size == 1
    next if arr.first == INITIAL_MARKER
    return arr.first == PLAYER_MARKER ? PLAYER : COMPUTER
  end
  nil
end

def player_turn!(board)
  input = ''
  loop do
    prompt("It's your turn. Enter: #{joinor(open_squares(board), ',')}")
    input = gets.chomp.to_i
    break if valid_input?(input, board)
    prompt('Sorry, that\'s not a valid choice')
  end
  board[input] = PLAYER_MARKER
end

def line_rating(line)
  return IMPROBABLE_WIN if line.empty?
  if line.size == 1
    line.first == COMPUTER_MARKER ? POSSIBLE_WIN : POSSIBLE_LOSS
  elsif line.uniq.size == 1
    line.uniq.first == COMPUTER_MARKER ? IMMINENT_WIN : IMMINENT_LOSS
  else
    IMPOSSIBLE_WIN_OR_LOSS
  end
end

def computer_turn!(board)
  square_ratings = (1..9).each_with_object({}) { |x, hsh| hsh[x] = 0 }
  open_squares(board).each do |square|
    WINNING_LINES.select { |a| a.include?(square) }.each do |line|
      line = line.map { |x| board[x] }.reject { |y| y == ' ' }
      square_ratings[square] += line_rating(line)
    end
  end
  board[square_ratings.max_by { |_, v| v }.first] = COMPUTER_MARKER
end

def place_piece!(board, current_player)
  current_player == COMPUTER ? computer_turn!(board) : player_turn!(board)
end

def alternate_player(current_player)
  current_player == PLAYER ? COMPUTER : PLAYER
end

def initialize_score
  { PLAYER => 0, COMPUTER => 0, TIE => 0 }
end

def initialize_first_player
  prompt("Would you like to play first? (y or [Any])")
  gets.chomp.downcase.start_with?('y') ? PLAYER : COMPUTER
end

def update_score!(score, board)
  winner?(board) ? score[detect_winner(board)] += 1 : score[TIE] += 1
end

def match_over?(score)
  score[PLAYER] >= 5 || score[COMPUTER] >= 5 || score[TIE] >= 5
end

def end_of_match_prompts(score)
  prompt('The match is over.')
  if score[PLAYER] >= 5
    prompt('You\'ve defeated the computer!')
  elsif score[COMPUTER] >= 5
    prompt('You LOST!')
  else
    prompt("You've tied 5 times.")
  end
  prompt("You you like to play again? (n or [Any])")
end

def end_of_game_prompts(board)
  if winner?(board)
    prompt("#{detect_winner(board)} won!")
  else
    prompt("The game ended in a tie.")
  end
  prompt("Press any key...")
end

def board_loop!(board, score, current_player)
  loop do
    display_board(board, score)
    place_piece!(board, current_player)
    display_board(board, score)
    current_player = alternate_player(current_player)
    break if winner?(board) || board_full?(board)
  end
end

loop do
  score = initialize_score
  marquee(score)
  first_player = initialize_first_player
  loop do
    current_player = first_player
    board = initialize_board
    board_loop!(board, score, current_player)
    update_score!(score, board)
    display_board(board, score)
    end_of_game_prompts(board)
    if gets
      break if match_over?(score)
      next
    end
  end

  if match_over?(score)
    end_of_match_prompts(score)
    break if gets.chomp.downcase.start_with?('n')
  end
end

prompt('Thanks for playing Tic-Tac-Toe. Goodbye!')
