class Agent
    attr_reader :x, :y
    attr_accessor :action

    ACTIONS = [:left, :right, :up, :down].freeze

    def initialize(start_x:, start_y:)
        @initial_position_x = start_x
        @initial_position_y = start_y
        reset
    end

    def reset
        @x = @initial_position_x
        @y = @initial_position_y
        @action = :right  # Initial action toward goal direction
    end

    def move(next_x:, next_y:)
        @x = next_x
        @y = next_y
    end

    def next_state
        case @action
        when :left  then [@x - 1, @y]
        when :right then [@x + 1, @y]
        when :up    then [@x, @y - 1]
        when :down  then [@x, @y + 1]
        else             [@x, @y]
        end
    end
end
