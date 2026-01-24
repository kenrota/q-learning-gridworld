class GameController
    def initialize(game:, max_episodes:, tick_interval:, on_repaint:, on_result:, on_episode_end:, on_save:)
        @game = game
        @max_episodes = max_episodes
        @tick_interval = tick_interval
        @on_repaint = on_repaint
        @on_result = on_result
        @on_episode_end = on_episode_end
        @on_save = on_save
        @episode = 0
    end

    def run
        while @episode < @max_episodes
            run_episode
        end
    end

    private

    def run_episode
        @episode += 1

        until @game.game_over
            sleep(@tick_interval)
            @game.step
            @on_repaint.call
        end

        @on_result.call(@game.result)
        @on_episode_end.call(@episode, @game.steps)
        @on_save.call
        @game.reset_game
        @on_repaint.call
    end
end
