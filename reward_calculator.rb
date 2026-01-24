require_relative 'config'

class RewardCalculator
    def initialize(rewards: Config::REWARDS)
        @rewards = rewards
    end

    def calculate(block)
        @rewards.fetch(block, 0)
    end
end
