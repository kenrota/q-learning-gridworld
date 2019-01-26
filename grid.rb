class Grid
  attr_reader :grid

  GRID_WIDTH  = 10
  GRID_HEIGHT = 10
  BLOCK_SIZE  = 15

  AGENT_START_POS_X = 1
  AGENT_START_POS_Y = 1

  S = :start
  G = :goal
  L = :land
  H = :hole

  def initialize
    @grid = [
      [H, H, H, H, H, H, H, H, H, H,],
      [H, S, L, L, L, L, L, L, L, H,],
      [H, L, L, L, L, L, L, L, L, H,],
      [H, L, L, L, L, L, L, L, L, H,],
      [H, L, L, L, L, L, H, L, L, H,],
      [H, L, L, L, L, L, L, L, L, H,],
      [H, H, L, L, L, L, L, L, L, H,],
      [H, L, L, L, L, L, L, L, L, H,],
      [H, L, L, L, L, L, L, L, G, H,],
      [H, H, H, H, H, H, H, H, H, H,],
    ]
  end

  def get_reward(next_block)
    case next_block
    when H then -1
    when G then 1
    else        0
    end
  end
end
