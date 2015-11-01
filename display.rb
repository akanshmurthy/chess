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
    puts "Fill the grid!"
    puts "Use arrow keys to move & space to select/drop."
    build_grid.each { |row| puts row.join }
  end
end
