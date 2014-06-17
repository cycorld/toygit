require 'rugged'

module ToyGit
  class Command
    def initialize
      path = Rugged::Repository.discover('.')
      @repo = Rugged::Repository.new(path)
    end
  end
end
