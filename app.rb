require 'java'
require_relative 'grid'
require_relative 'agent'
require_relative 'game'
require_relative 'q_learner'

java_import java.awt.Color
java_import java.awt.BasicStroke
java_import javax.swing.JFrame

class App < JFrame
    EPISODE_MAX = 1000

    WINDOW_POS_X  = 0
    WINDOW_POS_Y  = 0
    WINDOW_WIDTH  = 152
    WINDOW_HEIGHT = 174
    GRID_OFFSET_X = 1
    GRID_OFFSET_Y = 23

    def initialize
        super
        @grid = Grid.new
        @agent = Agent.new(Grid::AGENT_START_POS_X, Grid::AGENT_START_POS_Y)
        @q_learner = QLearner.new(Grid::GRID_WIDTH, Grid::GRID_HEIGHT, Agent::ACTIONS)
        @game = Game.new(@grid, @agent, @q_learner)
        @episodes = 0
        initUi
    end

    def run
        while(@episodes < EPISODE_MAX) do
            inclement_episods
            while(!@game.game_over)
                # Tweak tick speed to check agent's movement with eyes.
                sleep(0.5)
                tick
            end
            puts "#{@episodes},#{@game.steps},#{@game.calculate_winning_percentage}"
            @q_learner.save_q_table_to_file
            @game.reset_game
            repaint
        end
    end

    def inclement_episods
        @episodes += 1
    end

    def tick
        @game.step
        repaint
    end

    def initUi
        setTitle('Grid World')
        setBounds(WINDOW_POS_X, WINDOW_POS_Y, WINDOW_WIDTH, WINDOW_HEIGHT)
        setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
        setVisible(true)
    end

    def paint(g)
        drawGrid(g)
        drawAgent(g)
    end

    def drawGrid(g)
        Grid::GRID_HEIGHT.times do |y|
            Grid::GRID_WIDTH.times do |x|
                color = chooseColor(@grid.grid[y][x])
                drawBlock(g, x, y, color)
            end
        end
    end

    def chooseColor(block)
        case block
        when Grid::S then Color.new(0, 255, 0)
        when Grid::G then Color.new(0, 0, 255)
        when Grid::L then Color.new(210, 180, 140)
        when Grid::H then Color.new(0, 0, 0)
        end
    end

    def drawAgent(g)
        drawCircle(g, @agent.x, @agent.y, Color.new(255, 0, 0))
    end

    def drawBlock(g, x, y, color)
        g.setColor(Color::WHITE)
        g.setStroke(BasicStroke.new(2))
        g.drawRect(GRID_OFFSET_X + x * Grid::BLOCK_SIZE,
                   GRID_OFFSET_Y + y * Grid::BLOCK_SIZE,
                   Grid::BLOCK_SIZE,
                   Grid::BLOCK_SIZE)
        g.setColor(color)
        g.fillRect(GRID_OFFSET_X + x * Grid::BLOCK_SIZE,
                   GRID_OFFSET_Y + y * Grid::BLOCK_SIZE,
                   Grid::BLOCK_SIZE,
                   Grid::BLOCK_SIZE)
    end

    def drawCircle(g, x, y, color)
        g.setColor(color)
        g.fillOval(GRID_OFFSET_X + x * Grid::BLOCK_SIZE,
                   GRID_OFFSET_Y + y * Grid::BLOCK_SIZE,
                   Grid::BLOCK_SIZE - 1,
                   Grid::BLOCK_SIZE - 1)
    end
end
