require 'minitest/autorun'
require_relative '../agent'

class TestAgent < Minitest::Test
    def setup
        @agent = Agent.new(start_x: 1, start_y: 1)
    end

    def test_initial_position
        assert_equal 1, @agent.x
        assert_equal 1, @agent.y
    end

    def test_initial_action_is_right
        assert_equal :right, @agent.action
    end

    def test_move_updates_position
        @agent.move(next_x: 5, next_y: 3)
        assert_equal 5, @agent.x
        assert_equal 3, @agent.y
    end

    def test_reset_returns_to_initial_position
        @agent.move(next_x: 5, next_y: 5)
        @agent.reset
        assert_equal 1, @agent.x
        assert_equal 1, @agent.y
    end

    def test_next_state_left
        @agent.action = :left
        assert_equal [0, 1], @agent.next_state
    end

    def test_next_state_right
        @agent.action = :right
        assert_equal [2, 1], @agent.next_state
    end

    def test_next_state_up
        @agent.action = :up
        assert_equal [1, 0], @agent.next_state
    end

    def test_next_state_down
        @agent.action = :down
        assert_equal [1, 2], @agent.next_state
    end
end
