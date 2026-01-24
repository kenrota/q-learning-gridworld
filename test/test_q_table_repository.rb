require 'minitest/autorun'
require 'tempfile'
require 'json'
require_relative '../q_table_repository'

class TestQTableRepository < Minitest::Test
    def test_exists_returns_false_for_missing_file
        repo = QTableRepository.new('/nonexistent/path.json')
        refute repo.exists?
    end

    def test_exists_returns_true_for_existing_file
        Tempfile.create(['q_table', '.json']) do |f|
            repo = QTableRepository.new(f.path)
            assert repo.exists?
        end
    end

    def test_save_and_load_roundtrip
        Tempfile.create(['q_table', '.json']) do |f|
            repo = QTableRepository.new(f.path)
            actions = [:left, :right]

            # 2x2 grid, 2 actions (hash-based)
            original = [
                [{ left: 0.1, right: 0.2 }, { left: 0.3, right: 0.4 }],
                [{ left: 0.5, right: 0.6 }, { left: 0.7, right: 0.8 }]
            ]

            repo.save(original)
            loaded = repo.load(grid_width: 2, grid_height: 2, actions: actions)

            assert_equal original, loaded
        end
    end

    def test_save_creates_valid_json_with_metadata
        Tempfile.create(['q_table', '.json']) do |f|
            repo = QTableRepository.new(f.path)
            original = [
                [{ left: 0.1, right: 0.2 }, { left: 0.3, right: 0.4 }],
                [{ left: 0.5, right: 0.6 }, { left: 0.7, right: 0.8 }]
            ]

            repo.save(original)

            data = JSON.parse(File.read(f.path))
            assert_equal 2, data['metadata']['grid_width']
            assert_equal 2, data['metadata']['grid_height']
            assert_equal ['left', 'right'], data['metadata']['actions']
            assert_equal({ 'left' => 0.1, 'right' => 0.2 }, data['q_values']['0,0'])
            assert_equal({ 'left' => 0.7, 'right' => 0.8 }, data['q_values']['1,1'])
        end
    end

    def test_load_or_create_returns_new_table_when_no_file_exists
        repo = QTableRepository.new('/nonexistent/path.json')
        actions = [:left, :right, :up, :down]

        q_table = repo.load_or_create(grid_width: 2, grid_height: 2, actions: actions)

        assert_equal 2, q_table.size
        assert_equal 2, q_table[0].size
        assert_equal 4, q_table[0][0].size
        assert_equal actions, q_table[0][0].keys
    end

    def test_load_or_create_returns_random_values_when_no_file_exists
        repo = QTableRepository.new('/nonexistent/path.json')
        actions = [:left, :right, :up, :down]

        q_table = repo.load_or_create(grid_width: 2, grid_height: 2, actions: actions)

        q_table.each do |row|
            row.each do |cell|
                cell.values.each do |value|
                    assert value >= 0 && value < 1, "Expected random value between 0 and 1"
                end
            end
        end
    end

    def test_load_or_create_loads_from_file_when_exists
        Tempfile.create(['q_table', '.json']) do |f|
            repo = QTableRepository.new(f.path)
            actions = [:left, :right]
            original = [
                [{ left: 0.1, right: 0.2 }, { left: 0.3, right: 0.4 }],
                [{ left: 0.5, right: 0.6 }, { left: 0.7, right: 0.8 }]
            ]
            repo.save(original)

            loaded = repo.load_or_create(grid_width: 2, grid_height: 2, actions: actions)

            assert_equal original, loaded
        end
    end

    def test_load_raises_error_on_grid_size_mismatch
        Tempfile.create(['q_table', '.json']) do |f|
            repo = QTableRepository.new(f.path)
            original = [
                [{ left: 0.1, right: 0.2 }, { left: 0.3, right: 0.4 }],
                [{ left: 0.5, right: 0.6 }, { left: 0.7, right: 0.8 }]
            ]
            repo.save(original)

            assert_raises(QTableRepository::InvalidQTableError) do
                repo.load(grid_width: 3, grid_height: 3, actions: [:left, :right])
            end
        end
    end
end
