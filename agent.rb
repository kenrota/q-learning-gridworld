class Agent
    attr_reader :x, :y
    attr_accessor :action, :game

    LEFT  = 0
    RIGHT = 1
    UP    = 2
    DOWN  = 3
    ACTIONS = [LEFT, RIGHT, UP, DOWN]

    def initialize(initial_position_x, initial_position_y)
        @initial_position_x = initial_position_x
        @initial_position_y = initial_position_y
        reset
    end

    def reset
        @x = @initial_position_x
        @y = @initial_position_y
        @action = RIGHT
    end

    def move(next_x, next_y)
        @x = next_x
        @y = next_y
    end

    def get_next_state
        case @action
        when LEFT  then [@x - 1, @y]
        when RIGHT then [@x + 1, @y]
        when UP    then [@x, @y - 1]
        when DOWN  then [@x, @y + 1]
        else            [@x, @y]
        end
    end
end
