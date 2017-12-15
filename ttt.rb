INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
PLAYER = 'Player'
COMPUTER = 'Computer'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # across
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # down
                [[1, 5, 9], [3, 5, 7]]              # diagonal

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

def marquee
  system 'clear' or system 'cls'
  puts " -------------------"
  puts "|                   |"
  puts "|    Tic-Tac-Toe    |"
  puts "|                   |"
  puts " -------------------"
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def display_board(board)
  marquee
  puts "You're #{PLAYER_MARKER} and the computer is #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |"
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}"
  puts "     |     |"
  puts ""
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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
    return PLAYER if arr.first == PLAYER_MARKER
    return COMPUTER if arr.first == COMPUTER_MARKER
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
  return 2 if line.empty?
  if line.size == 1
    line.first == COMPUTER_MARKER ? 10 : 4
  elsif line.uniq.size == 1
    line.uniq.first == COMPUTER_MARKER ? 45 : 22
  else
    1
  end
end

def computer_turn!(board)
  square_ratings = (1..9).each_with_object({}) { |x, hsh| hsh[x] = -1 }
  open_squares(board).each do |square|
    WINNING_LINES.select { |a| a.include?(square) }.each do |line|
      line = line.map { |x| board[x] }.reject { |y| y == ' ' }
      square_ratings[square] += line_rating(line)
    end
  end
  board[square_ratings.max_by { |_, v| v }.first] = COMPUTER_MARKER
end

def place_piece!(board, current_player)
  computer_turn!(board) if current_player == COMPUTER
  player_turn!(board) if current_player == PLAYER
end

def alternate_player(current_player)
  return COMPUTER if current_player == PLAYER
  return PLAYER if current_player == COMPUTER
end

loop do
  marquee
  board = initialize_board

  current_player = COMPUTER
  prompt("Would you like to play first? (y or N)")
  current_player = PLAYER if gets.chomp.downcase.start_with?('y')

  loop do
    display_board(board)
    place_piece!(board, current_player)
    display_board(board)
    current_player = alternate_player(current_player)
    break if winner?(board) || board_full?(board)
  end

  if winner?(board)
    prompt("#{detect_winner(board)} won. Play again? (Y or n)")
  else
    prompt("The game ended in a tie. Play again? (Y or n)")
  end
  break if gets.chomp.downcase.start_with?('n')
end

prompt('Thanks for playing Tic-Tac-Toe. Goodbye!')
