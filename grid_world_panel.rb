require 'java'
require_relative 'config'

java_import javax.swing.JPanel
java_import java.awt.Color
java_import java.awt.BasicStroke

class GridWorldPanel < JPanel
    STROKE = BasicStroke.new(2)  # Grid border width in pixels

    def initialize(grid:, agent:, offset_x:, offset_y:)
        super()
        @grid = grid
        @agent = agent
        @offset_x = offset_x
        @offset_y = offset_y
        @block_size = Config::UI[:block_size]
        @agent_color = Color.new(*Config::UI[:agent_color])
        @colors = Config::UI[:colors].transform_values { |rgb| Color.new(*rgb) }
        setBackground(Color::BLACK)
    end

    # Override javax.swing.JPanel#paintComponent
    def paintComponent(g)
        java_method(:paintComponent, [java.awt.Graphics]).call(g)
        draw_grid(g)
        draw_agent(g)
    end

    private

    def draw_grid(g)
        Grid::HEIGHT.times do |y|
            Grid::WIDTH.times do |x|
                draw_block(
                    g: g,
                    x: x,
                    y: y,
                    color: @colors[@grid.block_at(x: x, y: y)]
                )
            end
        end
    end

    def draw_agent(g)
        g.setColor(@agent_color)
        g.fillOval(@offset_x + @agent.x * @block_size,
                   @offset_y + @agent.y * @block_size,
                   @block_size - 1,
                   @block_size - 1)
    end

    def draw_block(g:, x:, y:, color:)
        px = @offset_x + x * @block_size
        py = @offset_y + y * @block_size

        g.setColor(Color::WHITE)
        g.setStroke(STROKE)
        g.drawRect(px, py, @block_size, @block_size)

        g.setColor(color)
        g.fillRect(px, py, @block_size, @block_size)
    end
end
