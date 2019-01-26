class Game
    attr_reader :game_over, :steps

    def initialize(grid, agent, q_learner)
        @grid = grid
        @agent = agent
        @q_learner = q_learner
        @game_over = false
        @steps = 0
        @history = []
    end

    def step
        inclement_steps

        x = @agent.x
        y = @agent.y
        block = @grid.grid[y][x]
        @game_over = check_game_over(block)
        record_winning_result(block)
        return nil if @game_over

        next_x, next_y = @agent.get_next_state
        next_block = @grid.grid[next_y][next_x]
        reward = @grid.get_reward(next_block)
        @q_learner.update_q_table(x, y, next_x, next_y, reward, @agent.action)
        @agent.action = @q_learner.choose_next_action(next_x, next_y)
        @agent.move(next_x, next_y)
    end

    def inclement_steps
        @steps += 1
    end

    def reset_game
        @game_over = false
        @steps = 0
        @agent.reset
    end

    def check_game_over(block)
        block == Grid::H || block == Grid::G
    end

    def record_winning_result(block)
        if block == Grid::H
            @history << 0
        elsif block == Grid::G
            @history << 1
        end

        if @history.size > 100
            @history.shift(1)
        end
    end

    def calculate_winning_percentage
        sum = @history.inject { |sum, i| sum + i }
        ((sum.to_f / @history.size) * 100).round
    end
end
