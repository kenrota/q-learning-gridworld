require 'minitest/autorun'
require_relative '../game'
require_relative '../grid'
require_relative '../agent'

class MockQLearner
    attr_reader :update_called

    def initialize
        @update_called = false
    end

    def update_q_table(x:, y:, next_x:, next_y:, reward:, action:)
        @update_called = true
    end

    def choose_next_action(next_x:, next_y:)
        :right
    end
end

class MockRewardCalculator
    def calculate(block)
        0
    end
end

class TestGame < Minitest::Test
    def setup
        @grid = Grid.new
        @agent = Agent.new(
            start_x: Config::AGENT[:start_x],
            start_y: Config::AGENT[:start_y]
        )
        @q_learner = MockQLearner.new
        @reward_calculator = MockRewardCalculator.new
        @game = Game.new(
            grid: @grid,
            agent: @agent,
            q_learner: @q_learner,
            reward_calculator: @reward_calculator
        )
    end

    def test_initial_state
        refute @game.game_over
        assert_equal 0, @game.steps
        assert_nil @game.result
    end

    def test_step_increments_steps
        @game.step
        assert_equal 1, @game.steps
    end

    def test_step_calls_q_learner_when_not_game_over
        @game.step
        assert @q_learner.update_called
    end

    def test_step_on_hole_sets_game_over_and_lose
        # Move agent to hole position
        @agent.move(next_x: 0, next_y: 0)
        @game.step
        assert @game.game_over
        assert_equal :lose, @game.result
    end

    def test_step_on_goal_sets_game_over_and_win
        # Move agent to goal position
        @agent.move(next_x: 8, next_y: 8)
        @game.step
        assert @game.game_over
        assert_equal :win, @game.result
    end

    def test_step_on_land_does_not_end_game
        # Agent is on normal ground
        @game.step
        refute @game.game_over
        assert_nil @game.result
    end

    def test_reset_game_clears_state
        @game.step
        @game.step
        @game.reset_game

        refute @game.game_over
        assert_equal 0, @game.steps
        assert_nil @game.result
    end

    def test_reset_game_resets_agent_position
        @agent.move(next_x: 5, next_y: 5)
        @game.reset_game

        assert_equal Config::AGENT[:start_x], @agent.x
        assert_equal Config::AGENT[:start_y], @agent.y
    end
end
