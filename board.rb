require_relative 'piece'

class Board
  SIZE = 8
  def initialize(to_populate=true)
    @grid = Array.new(SIZE) {Array.new(SIZE)}
    populate if to_populate
  end

  def populate
    piece_arr = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    2.times do |iter1|
      SIZE.times do |iter2|
        if iter1 == 0
          self[iter1, iter2] = piece_arr[iter2].new(self, [iter1,iter2], :black)
          self[(-iter1-1), iter2] = piece_arr[iter2].new(self, [(SIZE-iter1-1),iter2], :white)
        elsif iter1 == 1
          self[iter1, iter2] = Pawn.new(self, [iter1,iter2], :black)
          self[(-iter1-1), iter2] = Pawn.new(self, [(SIZE-iter1-1),iter2], :white)
        end
      end
    end
    populate_empty_pieces
  end

  def populate_empty_pieces
    @grid.each_with_index do |row,i|
      row.map!.with_index do |square, j|
        if square.nil?
          square = EmptyPiece.new(self,[i,j], :clear)
        else
          square
        end
      end
    end
  end

  def [](i, j)
    @grid[i][j]
  end

  def []=(i, j, value)
    @grid[i][j] = value
  end

  def rows
    @grid
  end

  def in_bounds?(new_pos)
    (new_pos[0] >= 0 && new_pos[0] <= 7) && (new_pos[1] >= 0 && new_pos[1] <= 7)
  end

  def move!(start, end_pos)
    self[*start].update_piece_pos(end_pos)
    self[*end_pos] = self[*start]
    self[*start] = EmptyPiece.new(self, start, :clear)
  end

  def move(start, end_pos)
    # debugger
    if self[*start].valid_moves.include?(end_pos)
      self[*start].update_piece_pos(end_pos)
      self[*end_pos] = self[*start]
      self[*start] = EmptyPiece.new(self, start, :clear)
    else
    #   raise EndPosError
    # rescue EndPosError
      puts "Not a valid end position for this piece."
    end
    # raise NoPieceError
  end

  def in_check?(color)
    location = find_king(color)
    threat = opponents_can_move(color, location)
    puts "#{color} is in check!" if threat
    threat
  end

  def checkmate?(color)
    if in_check?(color)
      @grid.each_with_index do |row, i|
        row.each_with_index do |piece, j|
          next if piece.is_a?(EmptyPiece)
          if !piece.valid_moves.empty? && piece.color == color
            return false
          end
        end
      end
      true
    end

  end

  def find_king(color)
    @grid.each_with_index do |row, i|
      row.each_with_index do |element, j|
        if element.is_a?(King) && element.color == color
          return [i, j]
        end
      end
    end
  end

  def opponents_can_move(color, pos)
    poss_moves = []
    @grid.each_with_index do |row, i|
      row.each_with_index do |element, j|
        if element.color != color && !element.is_a?(EmptyPiece)
          poss_moves += element.moves
        end
      end
    end
    poss_moves.include?(pos)
  end

  def dup
    dup_board = Board.new(false)
    @grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        dup_piece = piece.piece_dup(dup_board, piece.pos.dup, piece.color)
        dup_board[i,j] = dup_piece
      end
    end
    dup_board
  end


end

class NoPieceError < StandardError
end

class EndPosError < StandardError
end
