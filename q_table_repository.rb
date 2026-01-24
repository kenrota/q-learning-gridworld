require 'json'

class QTableRepository
    class InvalidQTableError < StandardError; end

    DEFAULT_FILE = 'q_table.json'

    attr_reader :file_path

    def initialize(file_path = DEFAULT_FILE)
        @file_path = file_path
    end

    def exists?
        File.exist?(@file_path)
    end

    def save(q_table)
        grid_height = q_table.size
        grid_width = q_table[0].size
        actions = q_table[0][0].keys

        data = {
            'metadata' => {
                'grid_width' => grid_width,
                'grid_height' => grid_height,
                'actions' => actions.map(&:to_s)
            },
            'q_values' => build_q_values_hash(q_table)
        }

        File.open(@file_path, 'w') do |f|
            f.write(JSON.pretty_generate(data))
        end
    end

    def load(grid_width:, grid_height:, actions:)
        File.open(@file_path, 'r') do |f|
            data = JSON.parse(f.read)

            validate_metadata!(data, grid_width, grid_height, actions)

            build_q_table_from_hash(
                q_values_hash: data['q_values'],
                grid_width: grid_width,
                grid_height: grid_height,
                actions: actions
            )
        end
    end

    def load_or_create(grid_width:, grid_height:, actions:)
        if exists?
            load(grid_width: grid_width, grid_height: grid_height, actions: actions)
        else
            create_initial(grid_width: grid_width, grid_height: grid_height, actions: actions)
        end
    end

    private

    def create_initial(grid_width:, grid_height:, actions:)
        random = Random.new
        Array.new(grid_height) {
            Array.new(grid_width) {
                actions.each_with_object({}) { |action, hash| hash[action] = random.rand }
            }
        }
    end

    def build_q_values_hash(q_table)
        q_values = {}
        q_table.each_with_index do |row, y|
            row.each_with_index do |action_values, x|
                q_values["#{y},#{x}"] = action_values.transform_keys(&:to_s)
            end
        end
        q_values
    end

    def build_q_table_from_hash(q_values_hash:, grid_width:, grid_height:, actions:)
        q_table = Array.new(grid_height) {
            Array.new(grid_width) {
                actions.each_with_object({}) { |action, hash| hash[action] = 0.0 }
            }
        }

        q_values_hash.each do |key, values|
            y, x = key.split(',').map(&:to_i)
            values.each do |action_str, value|
                action = action_str.to_sym
                q_table[y][x][action] = value.to_f if q_table[y][x].key?(action)
            end
        end

        q_table
    end

    def validate_metadata!(data, grid_width, grid_height, actions)
        metadata = data['metadata']
        return unless metadata

        if metadata['grid_width'] != grid_width || metadata['grid_height'] != grid_height
            raise InvalidQTableError, "Grid size mismatch: expected #{grid_width}x#{grid_height}, got #{metadata['grid_width']}x#{metadata['grid_height']}"
        end

        if metadata['actions'].size != actions.size
            raise InvalidQTableError, "Actions size mismatch: expected #{actions.size}, got #{metadata['actions'].size}"
        end
    end
end
