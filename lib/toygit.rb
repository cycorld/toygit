require 'rugged'

module ToyGit
  class Command
    def initialize
      path = Rugged::Repository.discover('.')
      @repo = Rugged::Repository.new(path)
      raise 'Invalid ToyGit Repository' unless verify
    end

    private

    def verify
      master = @repo.ref('refs/heads/master')
      walker = Rugged::Walker.new(@repo)
      walker.push master.target
      walker.each do |commit|
        return false if commit.parents.count > 1
      end
      true
    end
  end
end
