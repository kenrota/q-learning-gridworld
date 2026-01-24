require_relative 'config'
require_relative 'grid'
require_relative 'agent'
require_relative 'game'
require_relative 'q_learner'
require_relative 'grid_world_panel'
require_relative 'game_controller'
require_relative 'q_table_repository'
require_relative 'reward_calculator'
require_relative 'statistics_tracker'

java_import javax.swing.JFrame

class App
    WINDOW = {
        title: 'Grid World',
        x: 0,
        y: 0,
        width: 170,
        height: 195,
        offset_x: 10,
        offset_y: 10
    }.freeze

    def initialize
        assemble_app
    end

    def run
        register_shutdown_hook
        @game_controller.run
    end

    def register_shutdown_hook
        hook = java.lang.Thread.new { @statistics_tracker.finish }
        java.lang.Runtime.getRuntime.addShutdownHook(hook)
    end

    private

    def assemble_app
        # Core state
        @grid = Grid.new
        @agent = Agent.new(
            start_x: Config::AGENT[:start_x],
            start_y: Config::AGENT[:start_y]
        )

        # Q-learning stack
        @q_table_repository = QTableRepository.new
        q_table = @q_table_repository.load_or_create(
            grid_width: Grid::WIDTH,
            grid_height: Grid::HEIGHT,
            actions: Agent::ACTIONS
        )
        @q_learner = QLearner.new(q_table: q_table, actions: Agent::ACTIONS)
        @reward_calculator = RewardCalculator.new

        # Game + reporting
        @game = Game.new(
            grid: @grid,
            agent: @agent,
            q_learner: @q_learner,
            reward_calculator: @reward_calculator
        )
        @statistics_tracker = StatisticsTracker.new

        # UI
        @panel = GridWorldPanel.new(
            grid: @grid,
            agent: @agent,
            offset_x: WINDOW[:offset_x],
            offset_y: WINDOW[:offset_y]
        )
        build_window(panel: @panel)

        # Controller loop
        @game_controller = GameController.new(
            game: @game,
            max_episodes: Config::EPISODE[:max],
            tick_interval: Config::EPISODE[:tick_interval],
            on_repaint: -> { @panel.repaint },
            on_result: ->(result) { @statistics_tracker.record(result == :win) },
            on_episode_end: ->(episode, steps) { @statistics_tracker.report_episode(episode: episode, steps: steps) },
            on_save: -> { @q_table_repository.save(@q_learner.q_table) }
        )
    end

    def build_window(panel:)
        JFrame.new.tap do |w|
            w.setTitle(WINDOW[:title])
            w.setBounds(
                WINDOW[:x],
                WINDOW[:y],
                WINDOW[:width],
                WINDOW[:height]
            )
            w.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
            w.add(panel)
            w.setVisible(true)
        end
    end
end
