require_relative 'config'

class QLearner
    attr_reader :q_table

    def initialize(q_table:, actions:,
                   alpha: Config::Q_LEARNING[:alpha],
                   gamma: Config::Q_LEARNING[:gamma],
                   epsilon: Config::Q_LEARNING[:epsilon])
        @q_table = q_table
        @actions = actions
        @alpha = alpha
        @gamma = gamma
        @epsilon = epsilon
        @random = Random.new
    end

    # Update Q-value using Bellman equation:
    # Q(s,a) ← Q(s,a) + α * [R + γ * max(Q(s')) - Q(s,a)]
    def update_q_table(x:, y:, next_x:, next_y:, reward:, action:)
        next_q_max = @q_table[next_y][next_x].values.max
        current_q = @q_table[y][x][action]
        td_error = reward + @gamma * next_q_max - current_q
        @q_table[y][x][action] = current_q + @alpha * td_error
    end

    def choose_next_action(next_x:, next_y:)
        if @random.rand < @epsilon
            @actions.sample
        else
            q_values = @q_table[next_y][next_x]
            q_values.max_by { |_, v| v }[0]
        end
    end
end
