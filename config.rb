require_relative 'grid'

module Config
  # Agent settings
  AGENT = {
    start_x: 1,
    start_y: 1
  }.freeze

  # Reward values for terminal states
  REWARDS = {
    Grid::HOLE => -1,  # Penalty for falling into hole
    Grid::GOAL => 1    # Reward for reaching goal
  }.freeze

  # Q-Learning hyperparameters
  Q_LEARNING = {
    alpha: 0.1,    # Learning rate: how much new information overrides old Q-value
    gamma: 0.9,    # Discount factor: importance weight of future rewards
    epsilon: 0.1   # Exploration rate: probability of taking random action
  }.freeze

  # UI settings
  UI = {
    block_size: 15,
    agent_color: [255, 0, 0],       # Red
    colors: {
      Grid::START => [0, 255, 0],      # Green
      Grid::GOAL => [0, 0, 255],       # Blue
      Grid::LAND => [210, 180, 140],   # Tan
      Grid::HOLE => [0, 0, 0]          # Black
    }.freeze
  }.freeze

  # Episode settings
  EPISODE = {
    max: 1000,
    tick_interval: 0.1
  }.freeze
end
