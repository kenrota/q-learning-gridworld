class Grid
  WIDTH  = 10
  HEIGHT = 10

  # Block types
  START = :start  # Agent initial position
  GOAL  = :goal   # Terminal state (success)
  LAND  = :land   # Walkable ground
  HOLE  = :hole   # Terminal state (failure)

  # Aliases for grid definition readability (class internal only)
  S = START
  G = GOAL
  L = LAND
  H = HOLE
  private_constant :S, :G, :L, :H

  def initialize
    @grid = [
      [H, H, H, H, H, H, H, H, H, H],
      [H, S, L, L, L, L, L, L, L, H],
      [H, L, L, L, L, L, L, L, L, H],
      [H, L, L, L, L, L, L, L, L, H],
      [H, L, L, L, L, L, H, L, L, H],
      [H, L, L, L, L, L, L, L, L, H],
      [H, H, L, L, L, L, L, L, L, H],
      [H, L, L, L, L, L, L, L, L, H],
      [H, L, L, L, L, L, L, L, G, H],
      [H, H, H, H, H, H, H, H, H, H]
    ]
  end

  def block_at(x:, y:)
    @grid[y][x]
  end
end
