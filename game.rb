require_relative 'display'

class Game
  def initialize
    @display = Display.new
  end

  def play
    loop do
      @display.cursor_pos = pick_square
        if @display.selected_pos.nil?
          @display.selected_pos = @display.cursor_pos
        else
          current_color = @display.board[*@display.selected_pos].color
          other_color = current_color == :white ? :black : :white
          @display.board.move(@display.selected_pos, @display.cursor_pos)
          if @display.board.in_check?(other_color)
            puts "#{other_color} is in check."
          end
          if @display.board.checkmate?(other_color)
            @display.render
            Kernel.abort("#{other_color} loses!")
          end
          @display.selected_pos = nil
        end
      @display.render
    end
  end

  def pick_square
    result = nil
    until result
      @display.render
      result = @display.get_input
    end
    result
  end


end


if $PROGRAM_NAME == __FILE__
  # running as script
  game = Game.new
  game.play
end
