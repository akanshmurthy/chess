require_relative 'display'

class Game
  def initialize
    @display = Display.new
    @display.play
  end
end


if $PROGRAM_NAME == __FILE__
  # running as script
  game = Game.new
end
