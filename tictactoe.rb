# 1. Display the initial empty 3x3 board.
# 2. Ask the user to mark a square.
# 3. Computer marks a square.
# 4. Display the updated board state.
# 5. If winner, display winner.
# 6. If board is full, display tie.
# 7. If neither winner nor board is full, go to #2
# 8. Play again?
# 9. If yes, go to #1
# 10. Good bye!

INITIAL_MARKER = ' '
PLAYER_MARK = 'X'
COMPUTER_MARK = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # across
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # down
                [[1, 5, 9], [3, 5, 7]]              # diagonal

def joinor(arr, delimiter)
  arr.map!(&:to_s)
  result = ''
  return arr if arr.size == 1
  return arr.first + ' or ' + arr.last if arr.size == 2
  (1..arr.size - 2).each do |x|
    result << delimiter + ' ' + arr[x]
  end
  arr.first + result + ' or ' + arr.last
end

def prompt(message)
  puts "=> #{message}"
end

# rubocop:disable Metrics/AbcSize
def display_board(board)
  system "clear" or system "cls"
  puts "You're a #{PLAYER_MARK} and the computer is #{COMPUTER_MARK}"
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

# rubocop:enable Metrics/AbcSize

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
    arr.map! { |x| board[x] }
    next unless arr.uniq.size == 1
    next if arr.first == INITIAL_MARKER
    return 'Player' if arr.first == PLAYER_MARK
    return 'Computer' if arr.first == COMPUTER_MARK
  end
  nil
end

def keep_score!(score, board)
  score[:player] += 1 if detect_winner(board) == 'Player'
  score[:computer] += 1 if detect_winner(board) == 'Computer'
end

def player_turn!(board)
  input = ''
  loop do
    prompt("Enter: #{joinor(open_squares(board),',')}")
    input = gets.chomp.to_i
    break if valid_input?(input, board)
    prompt('Sorry, that\'s not a valid choice')
  end
  board[input] = PLAYER_MARK
end

def computer_turn!(board)
  board[open_squares(board).sample] = COMPUTER_MARK
end

loop do
  board = initialize_board
  score = {player: 0, computer: 0}
  player_turn = -1

  loop do
    display_board(board)
    player_turn!(board)
    keep_score!(score, board)
    break if winner?(board) || board_full?(board)
    computer_turn!(board)
    keep_score!(score, board)
    break if winner?(board) || board_full?(board)
  end

  display_board(board)

  if winner?(board)
    prompt("#{detect_winner(board)} won. Play again?")
  else
    prompt("The game ended in a tie. Play again?")
  end
  break if gets.chomp.downcase.start_with?('n')
end

prompt('Thanks for playing Tic-Tac-Toe. Goodbye!')
