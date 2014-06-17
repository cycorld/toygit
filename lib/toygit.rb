require 'rugged'

module ToyGit
  class Command
    def initialize
      @repo = Rugged::Repository.new('.')
    end
  end
end
