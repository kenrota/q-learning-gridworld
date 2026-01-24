require 'minitest/autorun'
require 'stringio'
require_relative '../statistics_tracker'

class TestStatisticsTracker < Minitest::Test
    def test_empty_history_returns_zero
        tracker = StatisticsTracker.new
        assert_equal 0, tracker.winning_percentage
    end

    def test_all_wins_returns_100
        tracker = StatisticsTracker.new
        10.times { tracker.record(true) }
        assert_equal 100, tracker.winning_percentage
    end

    def test_all_losses_returns_0
        tracker = StatisticsTracker.new
        10.times { tracker.record(false) }
        assert_equal 0, tracker.winning_percentage
    end

    def test_half_wins_returns_50
        tracker = StatisticsTracker.new
        5.times { tracker.record(true) }
        5.times { tracker.record(false) }
        assert_equal 50, tracker.winning_percentage
    end

    def test_window_size_limits_history
        tracker = StatisticsTracker.new(window_size: 10)
        # Record 10 wins
        10.times { tracker.record(true) }
        assert_equal 100, tracker.winning_percentage

        # Record 10 more losses (old 10 wins are removed)
        10.times { tracker.record(false) }
        assert_equal 0, tracker.winning_percentage
    end

    def test_report_episode_outputs_episode_steps_and_percentage
        output = StringIO.new
        tracker = StatisticsTracker.new(window_size: 100, output: output)
        5.times { tracker.record(true) }
        5.times { tracker.record(false) }

        tracker.report_episode(episode: 10, steps: 25)

        assert_equal "\rEpisode: 10, Steps: 25, Win Rate (last 100): 50%   ", output.string
    end

    def test_report_episode_with_zero_percentage
        output = StringIO.new
        tracker = StatisticsTracker.new(window_size: 100, output: output)
        tracker.record(false)

        tracker.report_episode(episode: 1, steps: 100)

        assert_equal "\rEpisode: 1, Steps: 100, Win Rate (last 100): 0%   ", output.string
    end

    def test_report_episode_with_hundred_percentage
        output = StringIO.new
        tracker = StatisticsTracker.new(window_size: 100, output: output)
        tracker.record(true)

        tracker.report_episode(episode: 1, steps: 50)

        assert_equal "\rEpisode: 1, Steps: 50, Win Rate (last 100): 100%   ", output.string
    end

    def test_finish_outputs_newline
        output = StringIO.new
        tracker = StatisticsTracker.new(output: output)

        tracker.finish

        assert_equal "\n", output.string
    end
end
