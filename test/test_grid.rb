require 'minitest/autorun'
require_relative '../grid'

class TestGrid < Minitest::Test
    def setup
        @grid = Grid.new
    end

    def test_start_position
        block = @grid.block_at(x: Config::AGENT[:start_x], y: Config::AGENT[:start_y])
        assert_equal Grid::START, block
    end

    def test_goal_position
        block = @grid.block_at(x: 8, y: 8)
        assert_equal Grid::GOAL, block
    end

    def test_corners_are_holes
        assert_equal Grid::HOLE, @grid.block_at(x: 0, y: 0)
        assert_equal Grid::HOLE, @grid.block_at(x: 9, y: 0)
        assert_equal Grid::HOLE, @grid.block_at(x: 0, y: 9)
        assert_equal Grid::HOLE, @grid.block_at(x: 9, y: 9)
    end

    def test_inner_land
        assert_equal Grid::LAND, @grid.block_at(x: 2, y: 2)
        assert_equal Grid::LAND, @grid.block_at(x: 5, y: 5)
    end

    def test_inner_holes
        assert_equal Grid::HOLE, @grid.block_at(x: 6, y: 4)
        assert_equal Grid::HOLE, @grid.block_at(x: 1, y: 6)
    end
end
