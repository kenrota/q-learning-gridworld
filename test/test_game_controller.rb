require 'minitest/autorun'
require_relative '../game_controller'

class MockGame
    attr_accessor :game_over, :result, :steps
    attr_reader :step_count, :reset_count

    def initialize(steps_until_game_over: 3)
        @steps_until_game_over = steps_until_game_over
        @game_over = false
        @result = nil
        @steps = 0
        @step_count = 0
        @reset_count = 0
    end

    def step
        @step_count += 1
        @steps += 1
        if @step_count >= @steps_until_game_over
            @game_over = true
            @result = :win
        end
    end

    def reset_game
        @reset_count += 1
        @game_over = false
        @result = nil
        @steps = 0
        @step_count = 0
    end
end

class TestGameController < Minitest::Test
    def setup
        @game = MockGame.new(steps_until_game_over: 3)
        @repaint_count = 0
        @result_calls = []
        @episode_end_calls = []
        @save_count = 0

        @controller = GameController.new(
            game: @game,
            max_episodes: 2,
            tick_interval: 0,
            on_repaint: -> { @repaint_count += 1 },
            on_result: ->(result) { @result_calls << result },
            on_episode_end: ->(episode, steps) { @episode_end_calls << { episode: episode, steps: steps } },
            on_save: -> { @save_count += 1 }
        )
    end

    def test_run_executes_episodes_until_max_reached
        @controller.run
        assert_equal 2, @episode_end_calls.size
        assert_equal 3, @episode_end_calls[0][:steps]
        assert_equal 3, @episode_end_calls[1][:steps]
    end

    def test_on_repaint_called_each_step_and_after_reset
        @controller.run
        # 3 steps per episode + 1 after reset = 4 repaints per episode
        # 2 episodes = 8 total repaints
        assert_equal 8, @repaint_count
    end

    def test_on_result_called_with_game_result
        @controller.run
        assert_equal [:win, :win], @result_calls
    end

    def test_on_episode_end_receives_episode_number_and_steps
        @controller.run
        assert_equal 1, @episode_end_calls[0][:episode]
        assert_equal 2, @episode_end_calls[1][:episode]
    end

    def test_on_save_called_after_each_episode
        @controller.run
        assert_equal 2, @save_count
    end

    def test_game_reset_called_after_each_episode
        @controller.run
        assert_equal 2, @game.reset_count
    end
end
