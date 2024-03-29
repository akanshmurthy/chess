require 'colorize'
require_relative 'board'
require_relative 'cursorable'

class Display
  include Cursorable
  attr_accessor :cursor_pos, :selected, :selected_pos, :board
  def initialize(board = Board.new)
    @board = board
    @cursor_pos = [0, 0]
    @selected = false
    @selected_pos = nil
    @current_player = :white
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.to_s.colorize(color_options)
    end
  end

  def colors_for(i, j)
    bg = nil
    if [i, j] == @cursor_pos
      if @selected_pos.nil?
        bg = :light_red
      else
        bg = :green
      end
    elsif (i + j).odd?
      bg = :grey
    else
      bg = :white
    end
    { background: bg, color: @board[i,j].color }
  end

  def render
    system("clear")
    build_grid.each { |row| puts row.join }
    game_info
    instructions
  end

  def play
    loop do
      @cursor_pos = pick_square
        if @selected_pos.nil?
          @selected_pos = @cursor_pos
        else
          current_color = @board[*@selected_pos].color
          other_color = current_color == :white ? :black : :white
          @board.move(@selected_pos, @cursor_pos)
          @board.in_check?(other_color)
          if @board.checkmate?(other_color)
            render
            Kernel.abort("Checkmate - #{other_color} loses!")
          end
          @selected_pos = nil
          @current_player == :white ? @current_player = :black : @current_player = :white
        end
      render
    end
  end

  def game_info
    puts "Cursor at: #{cursor_pos} "
    puts "Current player: #{@current_player}"
  end

  def instructions
    puts "___________________________________________"
    puts "Instructions: Use arrow keys to move & space to select/drop. "
  end

  def pick_square
    result = nil
    until result
      self.render
      result = self.get_input
    end
    result
  end

end
