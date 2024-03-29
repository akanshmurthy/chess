require 'byebug'
SIZE = 8

class Piece
  attr_reader :pos, :color

  def initialize(board, pos, color)
    @pos = pos
    @board = board
    @color = color
  end

  def update_piece_pos(end_pos_array)
    @pos = end_pos_array if self.moves.include?(end_pos_array)
  end

  def valid_moves
    valid_moves = []
    self.moves.each do |move|
      valid_moves << move unless move_into_check?(move)
    end
    valid_moves
  end

  def move_into_check?(final_pos)
    board_dup = @board.dup
    board_dup.move!(@pos, final_pos)
    board_dup.in_check?(@color)
  end

  def piece_dup(board, pos, color)
    dup_piece = self.class.new(board, pos, color)
  end

end

class SlidingPiece < Piece

  def moves
    potential_moves = []
    move_dirs.each do |el|
      SIZE.times do |i|
        next if i.zero?
        a = pos[0] + (el[0] * i)
        b = pos[1] + (el[1] * i)
        break unless @board.in_bounds?([a,b])
        if @board[a,b].is_a?(EmptyPiece)
          potential_moves << [a,b]
        else
          potential_moves << [a,b] if @board[a,b].color != @color
          break
        end
      end
    end
    potential_moves
  end

end

class Bishop < SlidingPiece
  def move_dirs
    move_dirs = [[1,1],[1,-1],[-1,1],[-1,-1]]
  end

  def to_s
    color == :white ? "\u2657".white + " " : "\u265d".black + " "
  end
end

class Rook < SlidingPiece
  def move_dirs
    move_dirs = [[1,0],[-1,0],[0,1],[0,-1]]
  end

  def to_s
     color == :white ? "\u2656".white + " " : "\u265c".black + " "
  end

end

class Queen < SlidingPiece
  def move_dirs
    [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
  end

  def to_s
    color == :white ? "\u2655".white + " " : "\u265b".black + " "
  end

end

class SteppingPiece < Piece
  def moves
    potential_moves = []
    move_dirs.each do |el|
      a = pos[0] + el[0]
      b = pos[1] + el[1]
      next unless @board.in_bounds?([a,b])
      if @board[a,b].is_a?(EmptyPiece)
        potential_moves << [a,b]
      else
        potential_moves << [a,b] if @board[a,b].color != @color
      end
    end
    potential_moves
  end
end

class King < SteppingPiece
  def move_dirs
    move_dirs = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
  end

  def to_s
    color == :white ? "\u2654".white + " " : "\u265a".black + " "
  end

end

class Knight < SteppingPiece
  def move_dirs
    move_dirs = [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]
  end

  def to_s
    color == :white ? "\u2658".white + " " : "\u265e".black + " "
  end

end

class Pawn < Piece
  def to_s
    color == :white ? "\u2659".white + " " : "\u265f".black + " "
  end

  def moves
    moves = []
    if @color == :white
      move_right = [(pos[0] - 1), (pos[1] + 1)]
      move_left = [(pos[0] - 1), (pos[1] - 1)]
      if @board.in_bounds?(move_left) && @board[*move_left].color == :black
        moves << move_left
      end
      if @board.in_bounds?(move_right) && @board[*move_right].color == :black
        moves << move_right
      end
      if @pos.first == 6 && @board[(pos[0] - 1),pos[1]].is_a?(EmptyPiece) # second row, thus, it's the first move
        moves << [pos[0] -1, pos[1]]
        if @board[(pos[0] - 2),pos[1]].is_a?(EmptyPiece)
          moves << [(pos[0] - 2),pos[1]]
        end
      elsif @board[(pos[0] - 1),pos[1]].is_a?(EmptyPiece)
        moves << [(pos[0] - 1),pos[1]]
      end
    elsif @color == :black
      move_right = [(pos[0] + 1), (pos[1] + 1)]
      move_left = [(pos[0] + 1), (pos[1] - 1)]
      if @board.in_bounds?(move_right) && @board[*move_right].color == :white
        moves << move_right
      end
      if @board.in_bounds?(move_left) && @board[*move_left].color == :white
        moves << move_left
      end
      if @pos.first == 1 && @board[(pos[0] + 1),pos[1]].is_a?(EmptyPiece) # second row, thus, it's the first move
        moves << [pos[0] +1, pos[1]]
        if @board[(pos[0] + 2),pos[1]].is_a?(EmptyPiece)
          moves << [(pos[0] + 2),pos[1]]
        end
      elsif @board[(pos[0] + 1),pos[1]].is_a?(EmptyPiece)
        moves << [(pos[0] + 1),pos[1]]
      end
    end
    moves.select { |move| @board.in_bounds?(move) }
  end
end

class EmptyPiece < Piece
  def to_s
    "  "
  end

  def moves
    []
  end
end
