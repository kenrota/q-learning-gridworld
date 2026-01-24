require 'minitest/autorun'
require_relative '../q_learner'

class TestQLearner < Minitest::Test
    def setup
        # 2x2 grid, 4 actions (hash-based)
        @q_table = [
            [{ left: 0.1, right: 0.2, up: 0.3, down: 0.4 }, { left: 0.5, right: 0.6, up: 0.7, down: 0.8 }],
            [{ left: 0.2, right: 0.3, up: 0.4, down: 0.5 }, { left: 0.6, right: 0.7, up: 0.8, down: 0.9 }]
        ]
        @actions = [:left, :right, :up, :down]
        @learner = QLearner.new(q_table: @q_table, actions: @actions)
    end

    def test_update_q_table_modifies_value
        original_value = @q_table[0][0][:left]
        @learner.update_q_table(
            x: 0,
            y: 0,
            next_x: 1,
            next_y: 1,
            reward: 1.0,
            action: :left
        )
        refute_equal original_value, @q_table[0][0][:left]
    end

    def test_update_q_table_uses_bellman_equation
        # Q(s,a) = Q(s,a) + α * (r + γ * max(Q(s')) - Q(s,a))
        # α = 0.1, γ = 0.9
        # Q(0,0)[:left] = 0.1
        # max(Q(1,1)) = 0.9
        # reward = 1.0
        # new_value = 0.1 + 0.1 * (1.0 + 0.9 * 0.9 - 0.1) = 0.1 + 0.1 * 1.71 = 0.271
        @learner.update_q_table(
            x: 0,
            y: 0,
            next_x: 1,
            next_y: 1,
            reward: 1.0,
            action: :left
        )
        # Use assert_in_delta for floating-point comparison
        assert_in_delta 0.271, @q_table[0][0][:left], 0.001
    end

    def test_update_q_table_with_negative_reward
        # Q(s,a) = Q(s,a) + α * (r + γ * max(Q(s')) - Q(s,a))
        # α = 0.1, γ = 0.9
        # Q(0,0)[:left] = 0.1
        # max(Q(1,1)) = 0.9
        # reward = -1.0
        # new_value = 0.1 + 0.1 * (-1.0 + 0.9 * 0.9 - 0.1) = 0.1 + 0.1 * (-0.29) = 0.071
        @learner.update_q_table(
            x: 0,
            y: 0,
            next_x: 1,
            next_y: 1,
            reward: -1.0,
            action: :left
        )
        assert_in_delta 0.071, @q_table[0][0][:left], 0.001
    end

    def test_greedy_selects_max_q_value
        learner = QLearner.new(q_table: @q_table, actions: @actions, epsilon: 0)
        action = learner.choose_next_action(next_x: 0, next_y: 0)
        # @q_table[0][0] = { left: 0.1, right: 0.2, up: 0.3, down: 0.4 }
        assert_equal :down, action
    end

    def test_explore_selects_random_action
        learner = QLearner.new(q_table: @q_table, actions: @actions, epsilon: 1)
        action = learner.choose_next_action(next_x: 0, next_y: 0)
        assert_includes @actions, action
    end
end
