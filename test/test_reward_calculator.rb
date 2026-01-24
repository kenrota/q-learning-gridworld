require 'minitest/autorun'
require_relative '../grid'
require_relative '../reward_calculator'

class TestRewardCalculator < Minitest::Test
    def setup
        @calculator = RewardCalculator.new
    end

    def test_hole_returns_negative_reward
        assert_equal(-1, @calculator.calculate(Grid::HOLE))
    end

    def test_goal_returns_positive_reward
        assert_equal 1, @calculator.calculate(Grid::GOAL)
    end

    def test_land_returns_zero
        assert_equal 0, @calculator.calculate(Grid::LAND)
    end

    def test_start_returns_zero
        assert_equal 0, @calculator.calculate(Grid::START)
    end

    def test_custom_rewards
        custom = RewardCalculator.new(rewards: { Grid::GOAL => 100, Grid::HOLE => -50 })
        assert_equal 100, custom.calculate(Grid::GOAL)
        assert_equal(-50, custom.calculate(Grid::HOLE))
    end
end
