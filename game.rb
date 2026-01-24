require_relative 'grid'

class Game
    attr_reader :game_over, :steps, :result

    def initialize(grid:, agent:, q_learner:, reward_calculator:)
        @grid = grid
        @agent = agent
        @q_learner = q_learner
        @reward_calculator = reward_calculator
        @game_over = false
        @steps = 0
        @result = nil
    end

    def step
        increment_steps

        x = @agent.x
        y = @agent.y
        block = @grid.block_at(x: x, y: y)
        @game_over = check_game_over(block)
        @result = determine_result(block)
        return nil if @game_over

        train_step(x, y)
    end

    def reset_game
        @game_over = false
        @steps = 0
        @result = nil
        @agent.reset
    end

    private

    def train_step(x, y)
        next_x, next_y = @agent.next_state
        next_block = @grid.block_at(x: next_x, y: next_y)
        reward = @reward_calculator.calculate(next_block)

        @q_learner.update_q_table(
            x: x,
            y: y,
            next_x: next_x,
            next_y: next_y,
            reward: reward,
            action: @agent.action
        )
        @agent.action = @q_learner.choose_next_action(next_x: next_x, next_y: next_y)
        @agent.move(next_x: next_x, next_y: next_y)
    end

    def increment_steps
        @steps += 1
    end

    def check_game_over(block)
        block == Grid::HOLE || block == Grid::GOAL
    end

    def determine_result(block)
        case block
        when Grid::HOLE then :lose
        when Grid::GOAL then :win
        else nil
        end
    end
end
