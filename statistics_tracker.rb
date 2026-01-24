class StatisticsTracker
    # Sliding window size for calculating winning percentage
    DEFAULT_WINDOW_SIZE = 100

    def initialize(window_size: DEFAULT_WINDOW_SIZE, output: $stdout)
        @history = []
        @window_size = window_size
        @output = output
    end

    def record(won)
        @history << (won ? 1 : 0)
        @history.shift if @history.size > @window_size
    end

    def winning_percentage
        return 0 if @history.empty?
        ratio = @history.sum.to_f / @history.size
        (ratio * 100).round
    end

    def report_episode(episode:, steps:)
        # Clears leftover characters when new output is shorter than previous
        trailing_clear = '   '
        @output.print "\rEpisode: #{episode}, Steps: #{steps}, Win Rate (last #{@window_size}): #{winning_percentage}%#{trailing_clear}"
        @output.flush
    end

    def finish
        @output.puts
    end
end
