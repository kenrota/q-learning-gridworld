class QLearner
    ALPHA = 0.1
    GAMMA = 0.9
    EPSILON = 0.1
    Q_TABLE_FILE = 'q_table.csv'

    def initialize(grid_width, grid_height, actions)
        @grid_width = grid_width
        @grid_height = grid_height
        @actions = actions
        @random = Random.new
        initialize_q_table
        if File.exists?(Q_TABLE_FILE)
            q_table_size = grid_height * grid_width * actions.size
            resume_q_table_from_file(q_table_size)
        end
    end

    def initialize_q_table
        @q_table =
            Array.new(@grid_height).map {
                Array.new(@grid_width).map {
                    Array.new(@actions.size).map {
                        @random.rand
                    }
                }
            }
    end

    def save_q_table_to_file
        File.open(Q_TABLE_FILE, mode = 'w') do |f|
            f.write(@q_table.flatten.join(','))
        end
    end

    def resume_q_table_from_file(q_table_size)
         File.open(Q_TABLE_FILE, mode = 'r') do |f|
             q_values = f.read.split(',')
             if q_values.size != q_table_size
                 puts('[Error] q_table.csv is invalid size')
                 exit 1
             end

             i = 0
             @grid_width.times do |y|
                 @grid_height.times do |x|
                     @actions.size.times do |a|
                         @q_table[y][x][a] = q_values[i].to_f
                         i += 1
                     end
                 end
             end
         end
    end

    def update_q_table(x, y, next_x, next_y, reward, action)
        next_q_max = @q_table[next_y][next_x].max
        @q_table[y][x][action] =
            @q_table[y][x][action] + ALPHA * (reward + GAMMA * next_q_max - @q_table[y][x][action])
    end

    def choose_next_action(next_x, next_y)
        if @random.rand < EPSILON
            @actions.sample
        else
            @q_table[next_y][next_x].each_with_index.max[1]
        end
    end
end
